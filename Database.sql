CREATE DATABASE PerformanceResults
GO

USE PerformanceResults
GO

CREATE TABLE Results (
	RunDate DateTime,
	Url VARCHAR(200),
	AverageTime int,
	MaxTime int,
	MinTime int,
	NumberOfHits int,
	NumberOfErrors int,
	TestPlan int
)
