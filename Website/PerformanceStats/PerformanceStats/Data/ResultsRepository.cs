using System.Collections.Generic;
using System.Data.SqlClient;
using Dapper;
using PerformanceStats.Models;

namespace PerformanceStats.Data
{
    public class ResultsRepository
    {
        private const string sqlForDailyResults = @"
                SELECT Url, AVG(AverageTime) As AverageTime, CAST(RunDate as date) as RunDate FROM Results 
                WHERE TestPlan = @TestPlan
                GROUP BY CAST(RunDate as date), Url
                ORDER BY CAST(RunDate as date), Url";
        private const string sqlForHeartBeat = @"
                SELECT Url, AverageTime, RunDate FROM Results 
                WHERE TestPlan = @TestPlan
                AND RunDate > getdate() - 15
                ORDER BY RunDate Desc";

        private const string connectionString = "Data Source=(local); Initial Catalog=PerformanceResults; Integrated Security=SSPI";


        public IEnumerable<Result> GetDailyResultsForPerformanceTest(PlanDefinition testPlan)
        {
            return GetResults(sqlForDailyResults, testPlan);
        }

        public IEnumerable<Result> GetHeartBeatResultsForPerformanceTest(PlanDefinition testPlan)
        {
            return GetResults(sqlForHeartBeat, testPlan);
        }       

        private IEnumerable<Result> GetResults(string sql, PlanDefinition testPlan)
        {
            var sqlConnection = new SqlConnection(connectionString);
            sqlConnection.Open();
            var enumerable = sqlConnection.Query<Result>(sql, new {TestPlan = testPlan.Id} );
            sqlConnection.Close();
            return enumerable;
        }
    }
}