using System.Collections.Generic;
using System.Linq;

namespace PerformanceStats.Models
{
    public class GraphViewModel
    {
        public IEnumerable<Line> Daily { get; private set; }
        public IEnumerable<Line> HeartBeat { get; private set; }
        public string TestId { get; private set; }

        public GraphViewModel(string testId, IEnumerable<Line> daily, IEnumerable<Line> heartBeat)
        {
            Daily = daily;
            HeartBeat = heartBeat;
            TestId = testId;
        }

        public bool ContainsData()
        {
            return HeartBeat.Any();
        }

    }
}