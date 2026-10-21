using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace FoundrLink.Helpers
{
    public static class DbHelper
    {
        private static DateTime _offlineRetryTime = DateTime.MinValue;
        private static readonly object _stateLock = new object();

        public static string ConnectionString
        {
            get
            {
                var connSetting = ConfigurationManager.ConnectionStrings["FoundrLinkDb"];
                if (connSetting == null || string.IsNullOrWhiteSpace(connSetting.ConnectionString))
                {
                    return @"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=FoundrLinkDb;Integrated Security=True;MultipleActiveResultSets=True;Connect Timeout=3;";
                }
                return connSetting.ConnectionString;
            }
        }

        private static bool IsCircuitOpen
        {
            get
            {
                lock (_stateLock)
                {
                    return DateTime.UtcNow < _offlineRetryTime;
                }
            }
        }

        private static void TripCircuit()
        {
            lock (_stateLock)
            {
                _offlineRetryTime = DateTime.UtcNow.AddMinutes(1);
            }
        }

        public static SqlConnection GetConnection()
        {
            var conn = new SqlConnection(ConnectionString);
            if (conn.State != ConnectionState.Open)
            {
                conn.Open();
            }
            return conn;
        }

        public static int ExecuteNonQuery(string query, params SqlParameter[] parameters)
        {
            if (IsCircuitOpen)
            {
                return LocalFallbackStore.NonQuery(query, parameters);
            }

            try
            {
                using (var conn = GetConnection())
                using (var cmd = new SqlCommand(query, conn))
                {
                    if (parameters != null && parameters.Length > 0)
                    {
                        foreach (var p in parameters)
                        {
                            if (p != null)
                            {
                                if (p.Value == null) p.Value = DBNull.Value;
                                cmd.Parameters.Add(p);
                            }
                        }
                    }
                    return cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                TripCircuit();
                System.Diagnostics.Debug.WriteLine("DbHelper SQL Exception: " + ex.Message + ". Falling back to local offline store.");
                return LocalFallbackStore.NonQuery(query, parameters);
            }
        }

        public static object ExecuteScalar(string query, params SqlParameter[] parameters)
        {
            if (IsCircuitOpen)
            {
                return LocalFallbackStore.Scalar(query, parameters);
            }

            try
            {
                using (var conn = GetConnection())
                using (var cmd = new SqlCommand(query, conn))
                {
                    if (parameters != null && parameters.Length > 0)
                    {
                        foreach (var p in parameters)
                        {
                            if (p != null)
                            {
                                if (p.Value == null) p.Value = DBNull.Value;
                                cmd.Parameters.Add(p);
                            }
                        }
                    }
                    return cmd.ExecuteScalar();
                }
            }
            catch (Exception ex)
            {
                TripCircuit();
                System.Diagnostics.Debug.WriteLine("DbHelper SQL Exception: " + ex.Message + ". Falling back to local offline store.");
                return LocalFallbackStore.Scalar(query, parameters);
            }
        }

        public static DataTable ExecuteDataTable(string query, params SqlParameter[] parameters)
        {
            if (IsCircuitOpen)
            {
                return LocalFallbackStore.Query(query, parameters);
            }

            try
            {
                using (var conn = GetConnection())
                using (var cmd = new SqlCommand(query, conn))
                {
                    if (parameters != null && parameters.Length > 0)
                    {
                        foreach (var p in parameters)
                        {
                            if (p != null)
                            {
                                if (p.Value == null) p.Value = DBNull.Value;
                                cmd.Parameters.Add(p);
                            }
                        }
                    }
                    using (var adapter = new SqlDataAdapter(cmd))
                    {
                        var dt = new DataTable();
                        adapter.Fill(dt);
                        return dt;
                    }
                }
            }
            catch (Exception ex)
            {
                TripCircuit();
                System.Diagnostics.Debug.WriteLine("DbHelper SQL Exception: " + ex.Message + ". Falling back to local offline store.");
                return LocalFallbackStore.Query(query, parameters);
            }
        }

        public static SqlParameter CreateParam(string name, SqlDbType type, object value)
        {
            return new SqlParameter(name, type)
            {
                Value = value ?? DBNull.Value
            };
        }
    }
}
