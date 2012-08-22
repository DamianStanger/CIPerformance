using System.Collections.Generic;
using System.Linq;

namespace PerformanceStats.Models
{
    public class Line
    {    
        public string Url { get; set; }
        public IEnumerable<Result> Results { get; private set; }

        public Line(string url, IEnumerable<Result> results)
        {
            Url = url;
            Results = results;
        }

        public Line FillEmptyResults(int count)
        {
            List<Result> paddedResults = new List<Result>(count);
            int missingResults = count - Results.Count();

            for (int i = 0; i < missingResults; i++)
            {
                paddedResults.Add(new Result(){AverageTime=0,Url = Url });
            }
            paddedResults.AddRange(Results);
            Results = paddedResults;
            return this;
        }
    }
}