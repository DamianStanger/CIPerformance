using System;

namespace PerformanceStats.Models
{
    public class Result
    {
        public string Url { get; set; }
        public int AverageTime { get; set; }
        public double AverageTimeSeconds { 
            get { return AverageTime/1000D; }
        }
        public DateTime RunDate { get; set; }
    }
}