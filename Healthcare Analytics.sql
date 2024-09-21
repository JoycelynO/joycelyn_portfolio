--What is the demographic profile of the patient population, including age and gender distribution?

SELECT gender,
CASE WHEN DATEDIFF(year, date_of_birth, GETDATE()) BETWEEN 0 AND 17 THEN 'Pediatric'
	 WHEN DATEDIFF(year, date_of_birth, GETDATE()) BETWEEN 18 AND 64 THEN 'Adult'
	 ELSE 'Senior' END AS patient_category,
	 COUNT(patient_id) AS patient_count
FROM [Healthcare].[dbo].[Patients]
GROUP BY gender, 
CASE WHEN DATEDIFF(year, date_of_birth, GETDATE()) BETWEEN 0 AND 17 THEN 'Pediatric'
	 WHEN DATEDIFF(year, date_of_birth, GETDATE()) BETWEEN 18 AND 64 THEN 'Adult'
	 ELSE 'Senior' END
	 

/*Which diagnoses are most prevalent among patients, and how do they vary across different demographic groups,
including gender and age?*/
SELECT p.gender,
	   OPD.diagnosis,
CASE WHEN DATEDIFF(year, date_of_birth, GETDATE()) BETWEEN 0 AND 17 THEN 'Pediatric'
	 WHEN DATEDIFF(year, date_of_birth, GETDATE()) BETWEEN 18 AND 64 THEN 'Adult'
	 ELSE 'Senior' END AS patient_category,
	 COUNT(p.patient_id) AS patient_count
FROM [Healthcare].[dbo].[Patients] AS p
INNER JOIN [Healthcare].[dbo].[Outpatient Visits] AS OPD
ON p.patient_id = OPD.patient_id
GROUP BY p.gender, OPD.diagnosis,
CASE WHEN DATEDIFF(year, date_of_birth, GETDATE()) BETWEEN 0 AND 17 THEN 'Pediatric'
	 WHEN DATEDIFF(year, date_of_birth, GETDATE()) BETWEEN 18 AND 64 THEN 'Adult'
	 ELSE 'Senior' END
ORDER BY patient_count DESC;
	 

/*What are the most common appointment times throughout the day, and how does the distribution of apppointment
times vary across different hours?*/

SELECT  
	   DATEPART (hour, appointment_time) AS appointment_hour,
	   COUNT (*) AS num_of_appointments
FROM [Healthcare].[dbo].[Appointments]
GROUP BY DATEPART (hour, appointment_time)
ORDER BY num_of_appointments DESC;






--What are the most commonly ordered lab tests?

SELECT test_name,
	   COUNT (result_id) AS num_of_tests
FROM [Healthcare].[dbo].[Lab Results]
GROUP BY test_name
ORDER BY num_of_tests DESC;
	 

/*Typically, fasting blood sugar levels falls between 70-100 mg/dL. Our goal is to identify patients 
whose lab results are outside this normal range to implement early intervention.*/

Select P.patient_id,
	   P.patient_name,
       L.test_name,
	   L.result_value
FROM [Healthcare].[dbo].[Lab Results] AS L
INNER JOIN [Healthcare].[dbo].[Outpatient Visits] AS O
ON L.visit_id = O.visit_id
INNER JOIN [Healthcare].[dbo].[Patients] AS P
ON O.patient_id = P.patient_id
WHERE (test_name = 'Fasting Blood Sugar')
AND (result_value < 70 OR result_value > 100);



/* Assess how many patients are considered High, Medium, and Low Risk.

High Risk: patients who are smokers and have been diagnosed with either hypertension or diabetes
Medium Risk: patients who are non-smokers and have been diagnosed with either hypertension or diabetes
Low Risk: patients who do not fall into the High or Medium Risk categories. This includes patients who are not
smokers and do not have a diagnosis of hypertension or diabetes*/

SELECT
CASE WHEN smoker_status = 'Y' AND (diagnosis ='Hypertension' OR diagnosis = 'Diabetes') THEN 'High Risk'
	 WHEN smoker_status = 'N' AND (diagnosis = 'Hypertension' OR diagnosis = 'Diabetes') THEN 'Medium Risk'
	 ELSE 'Low Risk' END AS risk_category,
	 COUNT (patient_id) AS patient_count
FROM [Healthcare].[dbo].[Outpatient Visits]
GROUP BY CASE WHEN smoker_status = 'Y' AND (diagnosis ='Hypertension' OR diagnosis = 'Diabetes') THEN 'High Risk'
	 WHEN smoker_status = 'N' AND (diagnosis = 'Hypertension' OR diagnosis = 'Diabetes') THEN 'Medium Risk'
	 ELSE 'Low Risk' END


/* Find out information about the patients who had multiple visits within 30 days of their previous medical
visit

- Identify those patients
- Date of initial visit
- Reason of the initial visit
- Readmission date
- Reason for readmission
- Number of days between the initial visit and readmission
- Readmission visit recorded must have happened after the initial visit */


SELECT
	ov_initial.patient_id,
	ov_initial.visit_date AS initial_visit_date,
	ov_initial.reason_for_visit AS reason_for_initial_visit,
	ov_readmit.visit_date AS readmission_date,
	ov_readmit.reason_for_visit AS reason_for_readmission,
	DATEDIFF(day, ov_initial.visit_date, ov_readmit.visit_date) AS days_between_initial_and_readmission
FROM [Healthcare].[dbo].[Outpatient Visits] AS ov_initial
INNER JOIN [Healthcare].[dbo].[Outpatient Visits] AS ov_readmit
ON ov_initial.patient_id = ov_readmit.patient_id
WHERE DATEDIFF(day, ov_initial.visit_date, ov_readmit.visit_date) <= 30
AND ov_readmit.visit_date > ov_initial.visit_date

