using System.Collections.Generic;
namespace PerformanceStats.Models
{
    public class GraphsViewModel
    {
        private List<GraphViewModel> graphViewModels = new List<GraphViewModel>();
        public IEnumerable<GraphViewModel> Graphs 
        {
            get
            {
                return graphViewModels;
            }
        }

        public void AddGraphViewModel(GraphViewModel graphViewModel)
        {
            graphViewModels.Add(graphViewModel);
        }
    }
}