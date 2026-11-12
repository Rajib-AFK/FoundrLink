using System;
using System.Data;
using System.Data.SqlClient;

namespace FoundrLink.DataAccess
{
    /// <summary>
    /// Demonstrates Syllabus Unit 7: ADO.NET Disconnected Architecture (9 Hours).
    /// Implements:
    /// - SqlDataAdapter & DataSet
    /// - DataTable, DataColumn, DataRow
    /// - DataRelation (Master-Detail in-memory foreign key relationship)
    /// - DataView (Filtering and Sorting without database round-trips)
    /// - Disconnected CRUD Operations (Insert, Update, Delete)
    /// </summary>
    public class DisconnectedReportsRepository
    {
        /// <summary>
        /// Populates an in-memory DataSet containing Startups and OpenPositions,
        /// creates a DataRelation between them, and returns the populated DataSet.
        /// </summary>
        public DataSet GetStartupMasterDetailDataSet()
        {
            DataSet ds = new DataSet("FoundrLinkEcosystem");

            using (SqlConnection conn = DbConnectionFactory.CreateConnection())
            {
                // 1. SqlDataAdapter for parent table: Startups
                string sqlStartups = "SELECT StartupId, Name, Industry, Stage, FundingRaised, Status FROM dbo.Startups;";
                using (SqlDataAdapter adapterStartups = new SqlDataAdapter(sqlStartups, conn))
                {
                    adapterStartups.Fill(ds, "Startups");
                }

                // 2. SqlDataAdapter for child table: OpenPositions
                string sqlPositions = "SELECT PositionId, StartupId, Title, Location, PositionType FROM dbo.OpenPositions;";
                using (SqlDataAdapter adapterPositions = new SqlDataAdapter(sqlPositions, conn))
                {
                    adapterPositions.Fill(ds, "OpenPositions");
                }
            }

            // 3. Establish in-memory DataRelation (Master-Detail)
            if (ds.Tables["Startups"] != null && ds.Tables["OpenPositions"] != null)
            {
                DataTable parentTable = ds.Tables["Startups"];
                DataTable childTable = ds.Tables["OpenPositions"];

                DataColumn parentCol = parentTable.Columns["StartupId"];
                DataColumn childCol = childTable.Columns["StartupId"];

                if (parentCol != null && childCol != null)
                {
                    DataRelation rel = new DataRelation("Rel_Startup_Positions", parentCol, childCol, false);
                    ds.Relations.Add(rel);
                }
            }

            return ds;
        }

        /// <summary>
        /// Demonstrates DataView filtering and sorting on a DataTable (Unit 7).
        /// </summary>
        public DataView GetFilteredStartupsDataView(string industryFilter, decimal minFunding)
        {
            DataSet ds = new DataSet();
            using (SqlConnection conn = DbConnectionFactory.CreateConnection())
            {
                string sql = "SELECT StartupId, Name, Industry, Stage, FundingRaised, Status FROM dbo.Startups;";
                using (SqlDataAdapter adapter = new SqlDataAdapter(sql, conn))
                {
                    adapter.Fill(ds, "StartupsTable");
                }
            }

            DataTable table = ds.Tables["StartupsTable"];
            DataView view = new DataView(table);

            // In-memory filtering using RowFilter
            if (!string.IsNullOrEmpty(industryFilter) && !string.Equals(industryFilter, "All", StringComparison.OrdinalIgnoreCase))
            {
                view.RowFilter = string.Format("Industry = '{0}' AND FundingRaised >= {1}", industryFilter.Replace("'", "''"), minFunding);
            }
            else
            {
                view.RowFilter = string.Format("FundingRaised >= {0}", minFunding);
            }

            // In-memory sorting
            view.Sort = "FundingRaised DESC";

            return view;
        }

        /// <summary>
        /// Demonstrates Disconnected CRUD operations (Insert, Update, Delete) on DataTable (Unit 7).
        /// </summary>
        public bool PerformDisconnectedCRUDDemo(string testStartupName, string updatedName)
        {
            using (SqlConnection conn = DbConnectionFactory.CreateConnection())
            {
                string selectSql = "SELECT StartupId, FounderId, Name, Industry, Stage, ShortDescription, Status FROM dbo.Startups WHERE Name = @Name;";
                using (SqlDataAdapter adapter = new SqlDataAdapter(selectSql, conn))
                {
                    adapter.SelectCommand.Parameters.AddWithValue("@Name", testStartupName);

                    SqlCommandBuilder builder = new SqlCommandBuilder(adapter);
                    adapter.InsertCommand = builder.GetInsertCommand();
                    adapter.UpdateCommand = builder.GetUpdateCommand();
                    adapter.DeleteCommand = builder.GetDeleteCommand();

                    DataTable dt = new DataTable("Startups");
                    adapter.Fill(dt);

                    // 1. Disconnected INSERT via DataRow
                    DataRow newRow = dt.NewRow();
                    newRow["FounderId"] = 1; // Seeded founder
                    newRow["Name"] = testStartupName;
                    newRow["Industry"] = "AI/ML";
                    newRow["Stage"] = "Seed Stage";
                    newRow["ShortDescription"] = "Disconnected ADO.NET CRUD demonstration startup";
                    newRow["Status"] = "Draft";
                    dt.Rows.Add(newRow);

                    // Push insert to database
                    adapter.Update(dt);

                    // 2. Disconnected UPDATE via DataRow
                    if (dt.Rows.Count > 0)
                    {
                        dt.Rows[0]["Name"] = updatedName;
                        adapter.Update(dt);
                    }

                    // 3. Disconnected DELETE via DataRow
                    if (dt.Rows.Count > 0)
                    {
                        dt.Rows[0].Delete();
                        adapter.Update(dt);
                    }

                    return true;
                }
            }
        }

        /// <summary>
        /// Creates a programmatic in-memory DataTable with explicit DataColumns and DataRows.
        /// </summary>
        public DataTable BuildProgrammaticSummaryTable()
        {
            DataTable table = new DataTable("SystemKPIs");

            // Define DataColumns with CTS data types
            DataColumn colMetric = new DataColumn("MetricName", typeof(string));
            DataColumn colValue = new DataColumn("MetricValue", typeof(string));
            DataColumn colCategory = new DataColumn("Category", typeof(string));

            table.Columns.Add(colMetric);
            table.Columns.Add(colValue);
            table.Columns.Add(colCategory);

            // Add DataRows programmatically
            DataRow row1 = table.NewRow();
            row1["MetricName"] = "Active Startups";
            row1["MetricValue"] = "12";
            row1["Category"] = "Platform";
            table.Rows.Add(row1);

            DataRow row2 = table.NewRow();
            row2["MetricName"] = "Total Capital Deployed";
            row2["MetricValue"] = "₹28.5Cr";
            row2["Category"] = "Financial";
            table.Rows.Add(row2);

            DataRow row3 = table.NewRow();
            row3["MetricName"] = "Co-Founder Match Rate";
            row3["MetricValue"] = "94%";
            row3["Category"] = "Algorithmic";
            table.Rows.Add(row3);

            return table;
        }
    }
}
