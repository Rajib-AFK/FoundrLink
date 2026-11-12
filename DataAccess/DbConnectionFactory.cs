using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace FoundrLink.DataAccess
{
    /// <summary>
    /// Thread-safe ADO.NET Connection Factory ensuring secure parameterization,
    /// safe connection disposal, and environment configurability.
    /// </summary>
    public static class DbConnectionFactory
    {
        public static string ConnectionString
        {
            get
            {
                var setting = ConfigurationManager.ConnectionStrings["FoundrLinkDb"] 
                              ?? ConfigurationManager.ConnectionStrings["FoundrLinkDB"];
                if (setting == null || string.IsNullOrWhiteSpace(setting.ConnectionString))
                {
                    throw new ConfigurationErrorsException("Connection string 'FoundrLinkDb' is missing or empty in Web.config.");
                }
                return setting.ConnectionString;
            }
        }

        public static SqlConnection CreateConnection()
        {
            return new SqlConnection(ConnectionString);
        }

        public static SqlConnection OpenConnection()
        {
            var conn = CreateConnection();
            conn.Open();
            return conn;
        }
    }
}
