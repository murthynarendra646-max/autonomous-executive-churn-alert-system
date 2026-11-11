-- 1. Create and select the database
CREATE DATABASE IF NOT EXISTS saas_ops_monitor;
USE saas_ops_monitor;

-- 2. Reset tables if they already exist
DROP TABLE IF EXISTS api_usage_logs;
DROP TABLE IF EXISTS clients;

-- 3. Create the Clients table
CREATE TABLE clients (
    client_id INT PRIMARY KEY AUTO_INCREMENT,
    company_name VARCHAR(100) NOT NULL,
    account_tier VARCHAR(50) NOT NULL,
    mrr_usd DECIMAL(10, 2) NOT NULL,
    account_manager_email VARCHAR(100) NOT NULL
);

-- 4. Create the Daily API Usage Logs table
CREATE TABLE api_usage_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT NOT NULL,
    usage_date DATE NOT NULL,
    credits_used INT NOT NULL,
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

-- 5. Insert 6 B2B Clients
INSERT INTO clients (company_name, account_tier, mrr_usd, account_manager_email) VALUES
('Acme Corp', 'Enterprise', 4500.00, 'sarah.ops@startup.io'),
('Nexus Logistics', 'Growth', 1800.00, 'david.cs@startup.io'),
('Veloce FinTech', 'Enterprise', 6200.00, 'sarah.ops@startup.io'),
('Stratosphere AI', 'Starter', 600.00, 'maya.cs@startup.io'),
('OmniHealth Systems', 'Growth', 2400.00, 'david.cs@startup.io'),
('Kinetix Retail', 'Enterprise', 5100.00, 'sarah.ops@startup.io');

-- 6. Insert 60 Rows of Mock Usage Data (10 days per client)
INSERT INTO api_usage_logs (client_id, usage_date, credits_used) VALUES
(1, '2026-11-01', 9800), (1, '2026-11-02', 10200), (1, '2026-11-03', 10100),
(1, '2026-11-04', 9900), (1, '2026-11-05', 10500), (1, '2026-11-06', 10300),
(1, '2026-11-07', 9700), (1, '2026-11-08', 10400), (1, '2026-11-09', 10150),
(1, '2026-11-10', 9950),

(2, '2026-11-01', 4100), (2, '2026-11-02', 3950), (2, '2026-11-03', 4200),
(2, '2026-11-04', 4050), (2, '2026-11-05', 3900), (2, '2026-11-06', 4150),
(2, '2026-11-07', 4000), (2, '2026-11-08', 4100), (2, '2026-11-09', 3850),
(2, '2026-11-10', 600),

(3, '2026-11-01', 14500), (3, '2026-11-02', 14800), (3, '2026-11-03', 15100),
(3, '2026-11-04', 15000), (3, '2026-11-05', 15400), (3, '2026-11-06', 15600),
(3, '2026-11-07', 15300), (3, '2026-11-08', 15800), (3, '2026-11-09', 16000),
(3, '2026-11-10', 16200),

(4, '2026-11-01', 1200), (4, '2026-11-02', 1150), (4, '2026-11-03', 1300),
(4, '2026-11-04', 1250), (4, '2026-11-05', 1100), (4, '2026-11-06', 1220),
(4, '2026-11-07', 1180), (4, '2026-11-08', 1240), (4, '2026-11-09', 1190),
(4, '2026-11-10', 950),

(5, '2026-11-01', 6400), (5, '2026-11-02', 6600), (5, '2026-11-03', 6500),
(5, '2026-11-04', 6700), (5, '2026-11-05', 6450), (5, '2026-11-06', 6550),
(5, '2026-11-07', 6600), (5, '2026-11-08', 6500), (5, '2026-11-09', 6750),
(5, '2026-11-10', 6650),

(6, '2026-11-01', 12100), (6, '2026-11-02', 11900), (6, '2026-11-03', 12300),
(6, '2026-11-04', 12000), (6, '2026-11-05', 11800), (6, '2026-11-06', 12200),
(6, '2026-11-07', 12100), (6, '2026-11-08', 11950), (6, '2026-11-09', 12050),
(6, '2026-11-10', 1500);

-- 7. Create the Autonomous Churn Alert View
CREATE OR REPLACE VIEW vw_critical_usage_alerts AS
WITH RollingBaseline AS (
    SELECT 
        u.client_id,
        c.company_name,
        c.account_tier,
        c.mrr_usd,
        c.account_manager_email,
        u.usage_date,
        u.credits_used AS current_credits,
        ROUND(AVG(u.credits_used) OVER (
            PARTITION BY u.client_id 
            ORDER BY u.usage_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ), 0) AS baseline_7d_avg
    FROM api_usage_logs u
    JOIN clients c ON u.client_id = c.client_id
)
SELECT 
    company_name,
    account_tier,
    mrr_usd,
    account_manager_email,
    usage_date,
    current_credits,
    baseline_7d_avg,
    ROUND(((current_credits - baseline_7d_avg) / baseline_7d_avg) * 100, 1) AS pct_change
FROM RollingBaseline
WHERE usage_date = (SELECT MAX(usage_date) FROM api_usage_logs)
  AND baseline_7d_avg > 0
  AND ((current_credits - baseline_7d_avg) / baseline_7d_avg) <= -0.70;

-- 8. Test the View
SELECT * FROM vw_critical_usage_alerts;
