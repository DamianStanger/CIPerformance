using System.Web.Mvc;
using PerformanceStats.Data;
using PerformanceStats.Models;

namespace PerformanceStats.Controllers
{
    public class IndexController : Controller
    {
        private readonly LineMapper lineMapper = new LineMapper();
        private readonly ResultsRepository resultsRepository = new ResultsRepository();

        public ActionResult Index()
        {
            var viewModel = new GraphsViewModel(); 
            foreach (var testPlan in PlanDefinition.All)
            {
                var testPlanResults = GetResultsFor(testPlan);
                viewModel.AddGraphViewModel(testPlanResults);
            }
            return View(viewModel);
        }

        private GraphViewModel GetResultsFor(PlanDefinition definition)
        {
            var dailyResults = resultsRepository.GetDailyResultsForPerformanceTest(definition);
            var heartBeatResults = resultsRepository.GetHeartBeatResultsForPerformanceTest(definition);

            var dailyLines = lineMapper.MapToLines(dailyResults);
            var heartBeatLines = lineMapper.MapToLines(heartBeatResults);

            return new GraphViewModel(definition.Name, dailyLines, heartBeatLines);
        }
    }
}