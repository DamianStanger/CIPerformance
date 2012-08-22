using System.Collections.Generic;
namespace PerformanceStats.Models
{
    public class PlanDefinition
    {
        public int Id { get; private set; }
        public string Name { get; private set; }


        public static IEnumerable<PlanDefinition> All { get; private set; }
        
        static PlanDefinition(){
            All = CreateAllPlanDefinitions();
        }

        private static IEnumerable<PlanDefinition> CreateAllPlanDefinitions()
        {
            var all = new List<PlanDefinition>();

            all.Add(new PlanDefinition(1, "testPlan1"));
            all.Add(new PlanDefinition(2, "testPlan2"));
            
            return all;
        }

        //private constructor, you should define all your plan definitions in the static constructor above
        private PlanDefinition(int id, string name)
        {
            this.Id = id;
            this.Name = name;
        }

    }
}