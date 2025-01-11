USE insurance;

SELECT * 
FROM policy_churn;

SELECT 
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS Missing_Age,
    SUM(CASE WHEN Gender IS NULL THEN 1 ELSE 0 END) AS Missing_Gender,
    SUM(CASE WHEN Policy_Type IS NULL THEN 1 ELSE 0 END) AS Missing_Policy_Type
FROM policy_churn; -- Check for missing values

SELECT *
FROM policy_churn
WHERE Premium_Amount > (SELECT AVG(Premium_Amount) + 3 * STD(Premium_Amount) FROM policy_churn)
   OR Premium_Amount < (SELECT AVG(Premium_Amount) - 3 * STD(Premium_Amount) FROM policy_churn); -- Identify Outliers

SELECT CASE
           WHEN Age BETWEEN 18 AND 25 THEN '18-25'
           WHEN Age BETWEEN 26 AND 35 THEN '26-35'
           WHEN Age BETWEEN 36 AND 45 THEN '36-45'
           WHEN Age BETWEEN 46 AND 55 THEN '46-55'
           WHEN Age BETWEEN 56 AND 65 THEN '56-65'
           WHEN Age > 65 THEN '65+'
           ELSE 'Unknown'
       END AS Age_Group,
       AVG(Is_Churn) AS Churn_Rate,
       COUNT(*) AS Total_Customers,
       SUM(Is_Churn) AS Churn_Count
FROM policy_churn
GROUP BY Age_Group; -- Churn rate by age group

SELECT Income_Level,
       AVG(Is_Churn) AS Churn_Rate,
       COUNT(*) AS Total_Customers,
       SUM(Is_Churn) AS Churn_Count
FROM policy_churn
GROUP BY Income_Level; -- Churn rate by income level

SELECT Policy_Type, 
       AVG(Is_Churn) AS Churn_Rate,
       COUNT(*) AS Total_Customers,
       SUM(Is_Churn) AS Churn_Count,
       Gender,
       Income_Level
FROM policy_churn
GROUP BY Policy_Type, Gender, Income_Level; -- Churn rate by policy

SELECT CASE 
			WHEN Lifetime_Months < 20 THEN 'Short'
            WHEN Lifetime_Months >= 20 AND Lifetime_Months < 40 THEN 'Medium'
            WHEN Lifetime_Months >= 40 THEN 'Long'
            END Lifetime, 
       AVG(Is_Churn) AS Churn_Rate,
       COUNT(*) AS Total_Customers,
       SUM(Is_Churn) AS Churn_Count,
       Gender,
       Income_Level
FROM policy_churn
GROUP BY Lifetime, Gender, Income_Level
ORDER BY Lifetime; -- Churn rate by policy lifetime

SELECT Gender, Income_Level, 
CASE WHEN Is_Churn = 0 THEN 'Not Churned'
	 WHEN Is_Churn = 1 THEN 'Churned'
	END AS Churned, 
COUNT(Customer_ID)
FROM policy_churn
WHERE Feedback_Score <= 2
GROUP BY Gender, Income_Level, Is_Churn
ORDER BY Gender; -- Segment customers with low feedback scores and analyze their churn rates.

SELECT Gender, Income_Level, 
CASE WHEN Is_Churn = 0 THEN 'Not Churned'
	 WHEN Is_Churn = 1 THEN 'Churned'
	END AS Churned, 
COUNT(Customer_ID)
FROM policy_churn
WHERE Late_Payments >= 8
GROUP BY Gender, Income_Level, Is_Churn
ORDER BY Gender; -- Look for customers with multiple late payments, which may indicate a higher risk of churn.

SELECT AVG(Claims_Filed) AS Avg_Claims,
       AVG(Late_Payments) AS Avg_Late_Payments,
       AVG(Feedback_Score) AS Avg_Feedback_Score,
       SUM(CASE WHEN Is_Churn = 1 THEN 1 ELSE 0 END) AS Total_Churn,
       COUNT(*) AS Total_Customers
FROM policy_churn; -- Churn summary


/*The next query creates a risk scoring system to calculate a churn
risk score based on factors like feedback, late payments, policy lifetime,
claims filed, and policy type (with auto having a higher risk). Based on 
the scores, we can categorize customers into risk segments.*/
SELECT Customer_ID, Churn_Risk_Score,
       CASE 
           WHEN Churn_Risk_Score < 2 THEN 'Low Risk'
           WHEN Churn_Risk_Score >= 2 AND Churn_Risk_Score <= 2.3 THEN 'Medium Risk'
           WHEN Churn_Risk_Score > 2.3 THEN 'High Risk'
           ELSE 'Unknown'
       END AS Churn_Risk_Level
FROM (
    SELECT Customer_ID,
       CASE 
           WHEN Feedback_Score BETWEEN 1 AND 3 THEN 3
           WHEN Feedback_Score BETWEEN 4 AND 5 THEN 2
           WHEN Feedback_Score BETWEEN 6 AND 10 THEN 1
           ELSE 0
       END AS Feedback_Score_Risk,
       CASE 
           WHEN Late_Payments >= 4 THEN 3
           WHEN Late_Payments BETWEEN 2 AND 3 THEN 2
           WHEN Late_Payments BETWEEN 0 AND 1 THEN 1
           ELSE 0
       END AS Late_Payment_Risk,
       CASE 
           WHEN Lifetime_Months < 12 THEN 3
           WHEN Lifetime_Months BETWEEN 12 AND 24 THEN 2
           WHEN Lifetime_Months > 24 THEN 1
           ELSE 0
       END AS Lifetime_Month_Risk,
       CASE 
           WHEN Claims_Filed <= 1 THEN 3
           WHEN Claims_Filed BETWEEN 2 AND 3 THEN 2
           WHEN Claims_Filed > 3 THEN 1
           ELSE 0
       END AS Claims_Risk,
       CASE 
           WHEN Policy_Type = 'Auto' THEN 2  -- Assume Auto policies have higher churn
           WHEN Policy_Type = 'Health' THEN 1
           ELSE 0
       END AS Policy_Type_Risk,
       -- Calculate the total risk score
       (
           (CASE 
                WHEN Feedback_Score BETWEEN 1 AND 3 THEN 3
                WHEN Feedback_Score BETWEEN 4 AND 5 THEN 2
                WHEN Feedback_Score BETWEEN 6 AND 10 THEN 1
                ELSE 0
           END) * 0.3 + 
           (CASE 
                WHEN Late_Payments >= 4 THEN 3
                WHEN Late_Payments BETWEEN 2 AND 3 THEN 2
                WHEN Late_Payments BETWEEN 0 AND 1 THEN 1
                ELSE 0
           END) * 0.2 + 
           (CASE 
                WHEN Lifetime_Months < 12 THEN 3
                WHEN Lifetime_Months BETWEEN 12 AND 24 THEN 2
                WHEN Lifetime_Months > 24 THEN 1
                ELSE 0
           END) * 0.2 + 
           (CASE 
                WHEN Claims_Filed <= 1 THEN 3
                WHEN Claims_Filed BETWEEN 2 AND 3 THEN 2
                WHEN Claims_Filed > 3 THEN 1
                ELSE 0
           END) * 0.2 + 
           (CASE 
                WHEN Policy_Type = 'Auto' THEN 2
                WHEN Policy_Type = 'Health' THEN 1
                ELSE 0
           END) * 0.1
       ) AS Churn_Risk_Score
FROM policy_churn
) AS Risk_Scored_Customers; 