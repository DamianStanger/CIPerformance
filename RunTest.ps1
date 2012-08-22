$exe_fullpath = $MyInvocation.MyCommand.Definition
$exe_dirname = [System.IO.Path]::GetDirectoryName($exe_fullpath)

$connection_string = "Data Source=(local); Initial Catalog=PerformanceResults; Integrated Security=SSPI"

$jmeter_test_plan_load_caches = "LoadCaches"

$start_date_time = Get-Date -format s

Add-Type @'
  public class TestPlanDefinition
  {
    private int testNumber;
    private string testName;
    private string rootUrl;
    private string dir;
    
    public void Setup(int id, string testname, string rooturl, string directory)
    {
      testNumber = id;
      testName = testname;
      rootUrl = rooturl;
      dir = directory + '\\';
    }
    public int TestNumber()
    {
    	return testNumber;
    }
    public string TestName()
    {
    	return testName;
    }
    public string RootUrl()
    {
    	return rootUrl;
    }

    public string TestPlan()
    {
      return dir + testName + ".jmx";
    }
    public string TestLog()
    {
      return dir + testName + ".log";
    }
    public string TestResults()
    {
      return dir + testName + ".jtl";
    }
  }
'@

Add-Type @'
	public class PageStats
	{	
		private int numberOfHits;
		private int totalTime;
		private int max = 0;
		private int min = 99999;
		private int errors = 0;
		
		public void AddToTotalTime(int time)
		{
			totalTime += time;
			numberOfHits++;
			max = time > max ? time : max;
			min = time < min ? time : min;
		}	
		
		public void IncrementErrors()
		{
			errors++;
		}
		
		public decimal AverageTime()
		{
			return totalTime / numberOfHits;
		}
		
		public int Max()
		{
			return max;
		}
		public int Min()
		{
			return min;
		}
		public int NumberOfHits()
		{
			return numberOfHits;
		}
		public int NumberOfErrors()
		{
			return errors;
		}
	}
'@

function jmeter($test_plan) 
{
	$jmeter = "$($exe_dirname)\jMeter\bin\jmeter.bat"

	del $test_plan.TestLog() -ErrorAction SilentlyContinue
	del $test_plan.TestResults() -ErrorAction SilentlyContinue

	Write-Host "--------------------------------------------------"
	Write-Host "Running JMeter Performance Test" $test_plan.TestPlan()
	Write-Host "--------------------------------------------------"
	Write-Host $jmeter -n -t $test_plan.TestPlan() -l $test_plan.TestResults() -j $test_plan.TestLog()
	Write-Host ""
	
	& $jmeter -n -t $test_plan.TestPlan() -l $test_plan.TestResults() -j $test_plan.TestLog()
}

function PreLoadCaches()
{
	Write-Host "+++ Pre-Loading Cache +++"
	$cache = New-Object TestPlanDefinition
	$cache.Setup(0, $jmeter_test_plan_load_caches, "", $exe_dirname)
	jmeter $cache
	Write-Host "+++ Cache Loaded +++"
}

function ParseJmeterResults($file)
{
	$pages = @{}
	
	Write-Host "--------------------------------------------------"
	Write-Host "Parsing JMeter Results File" $file
	Write-Host "--------------------------------------------------"
	Write-Host ""
	
	[System.Xml.XmlDocument] $results = new-object System.Xml.XmlDocument
	$results.load($file)
	$samples = $results.selectnodes("/testResults/httpSample | /testResults/sample/httpSample")
	
	foreach ($sample in $samples) {
	
		$page_name = $sample.getAttribute("lb")
		
		if(!$pages.ContainsKey($page_name))
		{
			$new_page_stats = New-Object PageStats
			$pages.Add($page_name, $new_page_stats)
		}
  	  
		$page_stats = $pages.Get_Item($page_name)		
		$time = $sample.getAttribute("t")
		$page_stats.AddToTotalTime($time)
		
		$status = $sample.getAttribute("rc")
		if($status -ne 200 -band $status -ne 301 -band $status -ne 302) 
		{
			$page_stats.IncrementErrors()
		}
	}
	
	Write-Host "+++ Parsing finished +++" 

	return $pages
}

function WriteDataToDatabase($page_statistics, $test_plan_name) 
{
	Write-Host "--------------------------------------------------"
	Write-Host "Storing Results In Performance Database For" $test_plan_name
	Write-Host "--------------------------------------------------"
	Write-Host "page_statistics: " $page_statistics " test_plan:" $test_plan_name
	Write-Host ""
	
	$conn = New-Object System.Data.SqlClient.SqlConnection($connection_string)
	$conn.Open()

	foreach($pagestat in $page_statistics.GetEnumerator())
	{
		$cmd = $conn.CreateCommand()
		$name = $pagestat.Name
		$stats = $pagestat.Value
		$cmd.CommandText = "INSERT Results VALUES ('$start_date_time', '$($name)', $($stats.AverageTime()), $($stats.Max()), $($stats.Min()), $($stats.NumberOfHits()), $($stats.NumberOfErrors()), $test_plan_name)"
		Write-Host $cmd.CommandText
		$cmd.ExecuteNonQuery()
	}	

	$conn.Close()

	Write-Host "+++ Results Stored +++"
}

function KickStartApplication($application_url)
{
	Write-Host "--------------------------------------------------"
	Write-Host "+++ Kick Starting " $application_url "+++"
	Write-Host "--------------------------------------------------"
	Write-Host ""
	
	$request = [System.Net.WebRequest]::Create($($application_url))
	$response = $request.GetResponse()
	$requestStream = $response.GetResponseStream()
	$readStream = new-object System.IO.StreamReader $requestStream
	new-variable db
	$db = $readStream.ReadToEnd()
	$readStream.Close()
	$response.Close()
} 

function Main($tests) 
{
	Write-Host "--------------------------------------------------"
	Write-Host "+++ Main Start +++"
	Write-Host "--------------------------------------------------"
	Write-Host ""
  	
	foreach($test in $tests.GetEnumerator())
	{
	  	KickStartApplication $test.Value.RootUrl()
	}
  
	Write-Host "+++ Pausing 2 seconds whilst the servers start up +++"
	Start-Sleep -s 2	
	
	PreLoadCaches

  	foreach($test in $tests.GetEnumerator())
	{
	  	jmeter $test.Value
	  	$pagestatistics = ParseJmeterResults $test.Value.TestResults()
	  	WriteDataToDatabase $pagestatistics $test.Value.TestNumber()
  	}
  
	Write-Host "+++ Main Completed +++"
}

function CreateAllTestDefiniotions()
{
	$test_definitions = @{}

	$test1 = New-Object TestPlanDefinition
	$test2 = New-Object TestPlanDefinition
	$test1.Setup(1, "Performance1", "http://google.co.uk", $exe_dirname)
	$test2.Setup(2, "Performance2", "http://bing.co.uk", $exe_dirname)

	$test_definitions.Add(1, $test1);
	$test_definitions.Add(2, $test2);

	return $test_definitions
}


$tests = CreateAllTestDefiniotions
Main $tests