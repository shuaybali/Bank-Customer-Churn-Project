USE bank_customer;

SELECT * FROM dataset;


-- Data cleaning

 -- FIND Any duplicates , full record
 SELECT d.*
 FROM dataset d
 JOIN(
(SELECT CustomerID, COUNT(*) AS Dupli
FROM dataset
GROUP BY CustomerID
HAVING Dupli > 1)
)dup ON d.CustomerID = dup.CustomerID;

-- How many numbers are duplicated

WITH CTE AS
(SELECT CustomerID, COUNT(*) AS duplicated
FROM Dataset
GROUP BY CustomerID)
SELECT COUNT(*)
FROM CTE
WHERE duplicated > 1;

-- DELETE DUPLICATED
DELETE FROM Dataset
WHERE CustomerID IN(
SELECT CustomerID
FROM
(SELECT CustomerId,
ROW_NUMBER() OVER(PARTITION BY CustomerId ORDER BY CustomerId) AS Duplicated
FROM Dataset) AS QUERY
WHERE duplicated > 1
);

-- Chekc customers credit score and make categories
SELECT * FROM Dataset;

-- 300 579 Poor credit
-- 580 to 669 Fair credit
-- 670 to 739 Good credit
-- 740 to 799 Very good credit
-- 800 to 850 Ecellent credit

SELECT CASE
        WHEN CreditScore BETWEEN 300 AND 579 THEN 'Poor Credit'
        WHEN CreditScore BETWEEN 580 AND 669 THEN 'Fair Credit'
        WHEN CreditScore BETWEEN 670 AND 739 THEN 'Good Credit'
        WHEN CreditScore BETWEEN 740 AND 799 THEN 'Very good Credit'
        WHEN CreditScore BETWEEN 800 AND 850 THEN 'Exellent Credit'
        ELSE 'Unknown'
        END AS `Credit Category`
FROM Dataset;


ALTER TABLE Dataset
ADD COLUMN `Credit Category` VARCHAR(50) AFTER CreditScore;


-- UPDATE Credit Category column

UPDATE Dataset
SET `Credit Category` = CASE
        WHEN CreditScore BETWEEN 300 AND 579 THEN 'Poor Credit'
        WHEN CreditScore BETWEEN 580 AND 669 THEN 'Fair Credit'
        WHEN CreditScore BETWEEN 670 AND 739 THEN 'Good Credit'
        WHEN CreditScore BETWEEN 740 AND 799 THEN 'Very good Credit'
        WHEN CreditScore BETWEEN 800 AND 850 THEN 'Exellent Credit'
        ELSE 'Unknown'
        END;

-- View all dataset
SELECT * FROM Dataset;


-- WHAT IS THE AVG AGE OF THE CUSTOMERS

SELECT * FROM Dataset
WHERE Gender = '';

UPDATE Dataset
SET Gender ='Male'
WHERE Gender ='';


SELECT Gender, AVG(Age) AS `Average age`
FROM Dataset
GROUP BY Gender
ORDER BY `Average age`;


-- How many customers have exellent credit
SELECT * FROM Dataset
WHERE `Credit Category` = 'Exellent Credit';


SELECT COUNT(*) AS 'Exellent'
FROM Dataset
WHERE CreditScore =850;


-- Find customers who have the highest credit score in their respective age group:

SELECT CustomerId,Surname,Age,CreditScore,`Credit Category`
FROM(
SELECT CustomerId,Surname,Age,CreditScore,`Credit Category`,
RANK() OVER(PARTITION BY Age ORDER BY CreditScore DESC)AS RANK_NUM
FROM Dataset) AS RANKED
WHERE RANK_NUM =1;

-- Find the top 10 customers with the highest estimated salary who are also active members.

SELECT CustomerId, Surname, EstimatedSalary,
        RANK() OVER (ORDER BY EstimatedSalary DESC) AS RANK_NUM
        FROM Dataset
        WHERE IsActiveMember  = 1
        ORDER BY RANK_NUM
        LIMIT 10;



-- HOW MANY CUSTOMERS IS ACTIVE

SELECT DISTINCT(IsActiveMember) FROM Dataset;

SELECT * FROM dataset
WHERE IsActiveMember = 0;

SELECT IsActiveMember, COUNT(IsActiveMember) AS `Active number`
FROM Dataset
GROUP BY IsActiveMember;


-- What is the  numbers for each Credit category

SELECT * FROM DATASET;

SELECT `Credit Category`, COUNT(*) AS COUNT
FROM DATASET
GROUP BY `Credit Category`;

-- Show 3 Customers MAX EstimatedSalary

SELECT Gender,Geography,ROUND(MAX(EstimatedSalary),2) AS `Minumum salary`
FROM Dataset
GROUP BY Gender,Geography
ORDER BY `Minumum salary` DESC
LIMIT 3;


-- Calculate the percentage of customers who have exited by tenure:

SELECT COUNT(Tenure) FROM Data
WHERE Tenure = 1;

SELECT Tenure,
       COUNT(*) AS `Total customers`,
       SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS `Exited Customers`,
       (SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS Percenteage
FROM Dataset
GROUP BY Tenure
ORDER BY Tenure DESC;


-- Analyze the distribution of customers’ ages and genders across different geographies.
SELECT DISTINCT(Geography) FROM Dataset;

SELECT Geography,Gender,Age,
        AVG(Age) OVER (PARTITION BY Geography, Gender)AS AVG_Age,
        COUNT(*) OVER (PARTITION BY Geography, Gender )AS COUNT
FROM Dataset;


-- Analyze the trend of the number of products held by customers over different age groups.
SELECT * FROM Dataset;

WITH CTE AS
(SELECT Age,ROUND(AVG(NumOfProducts),3) AS `Number of prodcuts`
FROM Dataset
GROUP BY Age)
SELECT * FROM CTE
ORDER BY Age;


-- Analyze how having a credit card impacts the average balance and estimated salary of customers.
-- Falanqee sida haysashada kaarka deynta ay u saamayso celceliska dheelitirka iyo qiyaasta mushaharka macaamiisha.
SELECT * FROM Dataset;

WITH CreditCard_CTE AS 
(SELECT HasCrCard,
                ROUND(AVG(Balance),2)AS `Avg balance`, 
                ROUND(AVG(EstimatedSalary),2) AS `Avg salary`
FROM Dataset
GROUP BY HasCrCard)
SELECT * FROM CreditCard_CTE
ORDER BY `Avg balance`, `Avg salary` ;

-- Calculate a loyalty score based on tenure, number of products, and active membership
-- Xisaabi dhibcaha daacadnimada ee ku salaysan muddada, tirada alaabta, iyo xubinnimada firfircoon

SELECT CustomerID, Surname,
(Tenure *0.4 + NumOfProducts *0.3 + IsActiveMember *0.3 )AS Loyality
FROM Dataset;

-- FIND the maximum loylty score

WITH CTE AS (
SELECT CustomerID, Surname,
(Tenure *0.4 + NumOfProducts *0.3 + IsActiveMember *0.3 )AS Loyality
FROM Dataset
)
SELECT MAX(Loyality)AS `Highest loyalty score` FROM CTE
;

-- Find the top 10 most loyal customers based on the loyalty score
       
WITH Loyalty_CTE AS   
( SELECT CustomerID, Surname,
(Tenure *0.4 + NumOfProducts *0.3 + IsActiveMember *0.3)AS LoyltyScore
FROM Dataset)
SELECT CustomerID,Surname,LoyltyScore,
RANK() OVER (ORDER BY LoyltyScore) AS RANKK
FROM Loyalty_CTE
WHERE RANKK <= 10;






