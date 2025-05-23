-- 1) Most common diagnosis code in prediction data

SELECT diagnosis_code, COUNT(*) AS count
FROM diagnosis_predictions
GROUP BY diagnosis_code
ORDER BY count DESC
LIMIT 1;

-- 2) Unique people with confirmed diagnosis in Vascular Disease

SELECT COUNT(DISTINCT dp.person_id)
FROM diagnosis_predictions dp
JOIN diagnosis_descriptions dd
  ON dp.diagnosis_code = dd.diagnosis_code
WHERE dp.prediction_confirmed_as_true = TRUE
  AND dd.disease_category = 'Vascular Disease';

-- 3) Unique people with confirmed diagnoses in BOTH COPD and Specified Heart Arrhythmias

WITH confirmed_diagnoses AS (
  SELECT dp.person_id, dd.disease_category
  FROM diagnosis_predictions dp
  JOIN diagnosis_descriptions dd
    ON dp.diagnosis_code = dd.diagnosis_code
  WHERE dp.prediction_confirmed_as_true = TRUE
)
SELECT COUNT(*)
FROM (
  SELECT person_id
  FROM confirmed_diagnoses
  WHERE disease_category IN (
    'Chronic Obstructive Pulmonary Disease',
    'Specified Heart Arrhythmias'
  )
  GROUP BY person_id
  HAVING COUNT(DISTINCT disease_category) = 2
) AS both_conditions;


-- 4) Percent confirmed among COPD predictions with model 1 score ≥ 0.5

SELECT 
  ROUND(
    100.0 * SUM(CASE WHEN dp.prediction_confirmed_as_true = TRUE THEN 1 ELSE 0 END) 
    / COUNT(*), 2
  ) AS percent_confirmed
FROM diagnosis_predictions dp
JOIN diagnosis_descriptions dd
  ON dp.diagnosis_code = dd.diagnosis_code
WHERE dd.disease_category = 'Chronic Obstructive Pulmonary Disease'
  AND dp.prediction_model_1_score >= 0.5;


-- 5) Unique people with confirmed diagnosis in either COPD or Heart Arrhythmias and unconfirmed in Diabetes without Complication

WITH confirmed AS (
  SELECT DISTINCT person_id
  FROM diagnosis_predictions dp
  JOIN diagnosis_descriptions dd
    ON dp.diagnosis_code = dd.diagnosis_code
  WHERE dp.prediction_confirmed_as_true = TRUE
    AND dd.disease_category IN (
      'Chronic Obstructive Pulmonary Disease',
      'Specified Heart Arrhythmias'
    )
),
unconfirmed_diabetes AS (
  SELECT DISTINCT person_id
  FROM diagnosis_predictions dp
  JOIN diagnosis_descriptions dd
    ON dp.diagnosis_code = dd.diagnosis_code
  WHERE dp.prediction_confirmed_as_true = FALSE
    AND dd.disease_category = 'Diabetes without Complication'
)
SELECT COUNT(*)
FROM confirmed
JOIN unconfirmed_diabetes
  ON confirmed.person_id = unconfirmed_diabetes.person_id;