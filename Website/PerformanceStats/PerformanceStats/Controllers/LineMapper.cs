using System.Collections.Generic;
using System.Linq;
using PerformanceStats.Models;

namespace PerformanceStats.Controllers
{
    public class LineMapper
    {
        public IEnumerable<Line> MapToLines(IEnumerable<Result> results)
        {
            IEnumerable<Line> lines = results
                .OrderBy(x => x.RunDate)
                .GroupBy(x => x.Url)                
                .Select(x => new Line(x.Key, x.ToList()))
                .OrderBy(x => x.Url);
            return NormaliseLineResults(lines);
        }

        private IEnumerable<Line> NormaliseLineResults(IEnumerable<Line> lines)
        {            
            var maximumNumberOfResultsInAnyLine = 0;
            foreach (var line in lines)
            {
                maximumNumberOfResultsInAnyLine = line.Results.Count() > maximumNumberOfResultsInAnyLine ? line.Results.Count() : maximumNumberOfResultsInAnyLine;
            }

            return lines.Select(line => line.FillEmptyResults(maximumNumberOfResultsInAnyLine)).ToList();
        }
    }
}