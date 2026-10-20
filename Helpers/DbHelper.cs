using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace FoundrLink.Helpers
{
    public static class DbHelper
    {
        public static string ConnectionString
        {
            get
            {
                var connSetting = ConfigurationManager.ConnectionStrings["FoundrLinkDb"];
                if (connSetting == null || string.IsNullOrWhiteSpace(connSetting.ConnectionString))
                {
                    return @"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=FoundrLinkDb;Integrated Security=True;MultipleActiveResultSets=True;";
                }
                return connSetting.ConnectionString;
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

        public static object ExecuteScalar(string query, params SqlParameter[] parameters)
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

        public static DataTable ExecuteDataTable(string query, params SqlParameter[] parameters)
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

        public static SqlParameter CreateParam(string name, SqlDbType type, object value)
        {
            return new SqlParameter(name, type)
            {
                Value = value ?? DBNull.Value
            };
        }

        /// <summary>
        /// Executes a series of operations atomically within a single SQL transaction.
        /// </summary>
        public static void ExecuteInTransaction(Action<SqlConnection, SqlTransaction> action)
        {
            if (action == null) throw new ArgumentNullException(nameof(action));

            using (var conn = GetConnection())
            {
                using (var tx = conn.BeginTransaction())
                {
                    try
                    {
                        action(conn, tx);
                        tx.Commit();
                    }
                    catch
                    {
                        try { tx.Rollback(); } catch { }
                        throw;
                    }
                }
            }
        }
    }
}
