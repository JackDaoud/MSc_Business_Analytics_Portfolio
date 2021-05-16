-- Queries Ad_mgmt database 

-- Query 1
CREATE VIEW lm_imp_total AS
(SELECT sum(impressions) AS "LinkedIn_Total"
FROM linkedin_metrics);

CREATE VIEW fb_imp_total AS
(SELECT sum(lifetime_post_total_impressions) AS "Facebook_Total"
FROM facebook_metrics);

SELECT LinkedIn_Total AS " LinkedIn Total Impressions", Facebook_Total AS " Facebook Total Impressions"
FROM lm_imp_total
CROSS JOIN fb_imp_total;

-- Query 2
CREATE VIEW lm_imp AS
(SELECT ad_id, sum(impressions) AS "imp_lm"
FROM linkedin_metrics 
GROUP BY ad_id);

CREATE VIEW fb_imp AS
(SELECT ad_id, sum(lifetime_post_total_impressions) AS "imp_f"
FROM facebook_metrics 
GROUP BY ad_id);

CREATE VIEW campaign_overview_stats AS (SELECT a.campaign_id, 
SUM((SELECT SUM(imp_f) 
FROM fb_imp 
WHERE fb_imp.ad_id = a.ad_id)) 
AS "Total_Imp_Facebook", 
SUM((SELECT SUM(imp_lm) 
FROM lm_imp 
WHERE lm_imp.ad_id = a.ad_id))
AS "Total_Imp_LinkedIn"
FROM ads AS a
GROUP BY a.campaign_id);

CREATE VIEW FB_cost AS (
SELECT a.campaign_id,sum(a.cost) as "Facebook_Cost"
FROM ads AS a 
GROUP BY a.campaign_id, a.platform_id
HAVING platform_id IN ("FB"));

CREATE VIEW LI_cost AS (
SELECT a.campaign_id,sum(a.cost) AS "LinkedIn_Cost"
FROM ads AS a 
GROUP BY a.campaign_id, a.platform_id
HAVING platform_id IN ("LI"));

SELECT 
cos.campaign_id AS "Campaign ID",
cos.Total_Imp_Facebook AS "Total Impressions (FB)",
cos.Total_Imp_LinkedIn AS "Total Impressions (LI)",
Facebook_Cost AS "Total Cost (FB)",
LinkedIn_Cost AS "Total Cost (LI)",
Facebook_Cost/cos.Total_Imp_Facebook AS  "Cost per Impression (FB)",
LinkedIn_Cost/cos.Total_Imp_LinkedIN AS "Cost per Impression (LI)"
FROM campaign_overview_stats AS cos, FB_cost, LI_cost
WHERE cos.campaign_id = FB_cost.campaign_id
AND cos.campaign_id = LI_cost.campaign_id;

-- Query 3
SELECT campaign_id AS "Campaign ID", 
    	status_id AS "Status ID", 
    	planned_end_date AS "Planned End Date", 
    	end_date AS "Actual End Date", 
    	CURDATE() AS "Current Date"
FROM campaigns
WHERE planned_end_date < CURDATE()
AND end_date IS NULL
AND status_id != 3;

-- Query 4 
SELECT c.campaign_id AS "Campaign ID", 
    	c.planned_budget AS "Planned Budget", 
    	SUM(a.cost) AS "Actual Cost", 
    	c.planned_budget-SUM(a.cost) AS "Cost Delta"
FROM campaigns AS c, ads AS a 
WHERE c.campaign_id = a.campaign_id
AND c.status_id = 3
GROUP BY c.campaign_id;

-- Query 5 
SELECT c.campaign_id AS "Campaign ID", 
	COUNT(a.ad_id) AS "Number of Ads",
	c.planned_budget AS "Planned Budget", 
   	SUM(a.cost) AS "Sunk Cost"
FROM campaigns AS c, ads AS a 
WHERE c.campaign_id = a.campaign_id
AND c.status_id = 4
GROUP BY c.campaign_id;

-- Query 6
SELECT CONCAT(e.last_name, ', ', e.first_name) AS "Employee",
   	   c.campaign_id AS "Campaign ID",
	CASE 
		WHEN SUM(a.cost)-c.planned_budget > 0
		THEN SUM(a.cost)-c.planned_budget
		ELSE 0 
	END AS "Highest Overrun Cost"
FROM employees AS e, campaigns AS c, ads AS a
WHERE e.employee_id = c.employee_id
AND c.campaign_id = a.campaign_id
AND c.status_id = 3
GROUP BY c.campaign_id;

-- Query 7 
SELECT CONCAT(e.last_name, ', ', e.first_name) AS "Employee",
	   COUNT(a.ad_id) AS "Number of Ads"
FROM employees AS e, ads AS a, campaigns AS c
WHERE a.campaign_id = c.campaign_id
AND c.employee_id = e.employee_id
AND c.status_id IN (1, 3)
GROUP BY CONCAT(e.last_name, ', ', e.first_name)
ORDER BY COUNT(a.ad_id) DESC;

-- Query 8 
SELECT ps.contact_person AS "Product/Service Owner", 
	ps.ps_name AS "Product/Service", 
	COUNT(a.ad_id) AS "Count of Ads" 
FROM campaigns AS c, ads AS a, product_service AS ps 
WHERE  c.campaign_id = a.campaign_id 
AND c.ps_id = ps.ps_id 
AND ps.contact_person = "Thomas, Nussman" 
AND a.planned_end_date > CURDATE()
GROUP BY a.campaign_id;

-- Query 9 
CREATE VIEW cmp_ps AS
(SELECT c.ps_id,
	SUM(c.planned_budget) AS "Marketing_Budget",
    	SUM(a.cost) AS "Total_Expense"
FROM campaigns AS c, ads AS a
WHERE c.campaign_id = a.campaign_id
GROUP BY c.ps_id);

SELECT ps.contact_person AS "Product/Service Owner",
    	ps.ps_name AS "Product/Service",
   	cp.Marketing_Budget AS "Marketing Budget",
    	cp.Total_Expense AS "Total Expense"
FROM product_service AS ps, cmp_ps AS cp
WHERE ps.ps_id = cp.ps_id
AND ps.contact_person = "Jack, Black";

-- STORED PROCEDURES: 

-- Procedure 1 Update Budget (Stored Procedure) 

-- CREATE DEFINER=`root`@`localhost` PROCEDURE `update_budget`(
-- IN in_camp_id INT,
-- IN in_budget INT
-- )
-- BEGIN
-- DECLARE done INT DEFAULT FALSE;
-- DECLARE cur_camp_id INT;
-- DECLARE cur1 CURSOR FOR
--  	    	SELECT campaign_id
--               	FROM campaigns;
-- DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
-- OPEN cur1;
-- read_loop: LOOP
--    FETCH cur1 into cur_camp_id;
-- IF done THEN
--    		LEAVE read_loop;
--  	END IF;

-- UPDATE campaigns
-- SET planned_budget = planned_budget + in_budget
--      	WHERE campaign_id = cur_camp_id
--      	AND campaign_id = in_camp_id;
-- END LOOP;
-- CLOSE cur1;
--  
-- END

-- Check 1: Procedure 1 Update Budget (Stored Procedure) 
SELECT campaign_id AS "Campaign ID",
employee_id AS "Employee ID",
    	planned_budget AS "Budget"
FROM campaigns
WHERE campaign_id = 123;

CALL update_budget(123, 1000);

-- Check 2: Procedure 1 Update Budget (Stored Procedure) 
SELECT campaign_id AS "Campaign ID",
    	employee_id AS "Employee ID",
    	planned_budget AS "Budget"
FROM campaigns
WHERE campaign_id = 524;

CALL update_budget(524, 6000);

-- Check 3: Procedure 1 Update Budget (Stored Procedure) 
SELECT  campaign_id AS "Campaign ID",
    	employee_id AS "Employee ID",
    	planned_budget AS "Budget"
FROM campaigns
WHERE campaign_id = 219;

CALL update_budget(219, -1000);

-- Procedure 2 Update Status & Status tracking (Stored Procedure) 

-- CREATE DEFINER=`root`@`localhost` PROCEDURE `update_status`(IN in_emp INT, IN in_campaign_id INT, IN new_status INT, IN details_in VARCHAR(200))
-- BEGIN

-- DECLARE old_status INT;
-- DECLARE temp_cid INT;
-- DECLARE cur_time DATETIME;

-- SELECT c.campaign_id, c.status_id 
-- INTO temp_cid, old_status
-- FROM campaigns AS c 
-- WHERE c.campaign_id = in_campaign_id;

-- SELECT NOW()
-- INTO cur_time;

-- UPDATE campaigns as c2
-- SET c2.status_id = new_status
-- WHERE c2.campaign_id = temp_cid;

-- INSERT INTO `ad_mgmt`.`status_history`
-- (`campaign_id`,`employee_id`,`prev_status_id`,`update_time`,`details`)
-- VALUES (temp_cid, in_emp, old_status, cur_time, details_in);

-- END 

-- Check 1: Procedure 2 Update Status & Status tracking (Stored Procedure) 
SELECT c.campaign_id AS "Campaign ID",
c.status_id AS "Status ID",
sc.status_name AS "Status",
c.planned_start_date AS "Planned Start Date",
c.planned_end_date AS "Planned End Date",
c.start_date AS "Actual Start Date",
c.end_date AS "End Date",
CURDATE() AS "Today's Date"
FROM campaigns AS c, status_catalog AS sc
WHERE campaign_id = 524
AND c.status_id = sc.status_id;

CALL update_status(2,524,3,"The campaign is running late as identified by query, updating database to reflect this"); 

 -- Check 2: Procedure 2 Update Status & Status tracking (Stored Procedure) 
SELECT 
c.campaign_id AS "Campaign ID",
c.status_id AS "Status ID",
sc.status_name AS "Status",
c.planned_start_date AS "Planned Start Date",
c.planned_end_date AS "Planned End Date",
c.start_date AS "Actual Start Date",
c.end_date AS "End Date",
CURDATE() AS "Today's Date"
FROM campaigns AS c, status_catalog AS sc
WHERE campaign_id = 424
AND c.status_id = sc.status_id;

CALL update_status(4,456,1,"Change from hold to in progress as there is enough HR capacity now");
 
 -- Check 3: Procedure 2 Update Status & Status tracking (Stored Procedure) 
SELECT 
c.campaign_id AS "Campaign ID",
c.status_id AS "Status ID",
sc.status_name AS "Status",
c.planned_start_date AS "Planned Start Date",
c.planned_end_date AS "Planned End Date",
c.start_date AS "Actual Start Date",
c.end_date AS "End Date",
CURDATE() AS "Today's Date"
FROM campaigns AS c, status_catalog AS sc
WHERE campaign_id = 424
AND c.status_id = sc.status_id;

CALL update_status(4,456,1,"Change from hold to in progress as there is enough HR capacity now");
