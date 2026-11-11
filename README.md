# autonomous-executive-churn-alert-system 
# 🚨 Autonomous Executive Churn Alert System

### 📌 Business Problem
In B2B SaaS startups, a sudden drop in a client's daily API usage indicates either a broken technical integration or imminent subscription churn. Relying on analysts to manually refresh BI dashboards every morning delays intervention and puts recurring revenue (ARR/MRR) at risk.

### 💡 Automated Solution
This zero-code, autonomous RevOps pipeline monitors customer health 24/7 without manual intervention:
1. **Proactive SQL Anomaly Detection:** A MySQL `VIEW` powered by a **7-day rolling average window function (`OVER PARTITION BY`)** automatically isolates clients whose daily API credit consumption drops more than **70%** below their baseline.
2. **Scheduled Cloud Orchestration:** **Make.com** queries the cloud MySQL view daily and passes flagged high-risk accounts to an AI agent.
3. **Agentic AI Executive Briefing:** **Google Gemini AI** analyzes the revenue at risk (`MRR`), drop percentage, and account tier to generate a concise executive summary with immediate action steps for the Account Manager.
4. **Automated Stakeholder Delivery:** Alerts are logged automatically to an executive tracking sheet (and/or Slack) before the workday begins.

### 🏗️ System Architecture
![Architecture Diagram](architecture_diagram.png)

### ⚙️ Automation Workflow & Live Output
![Make.com Workflow](make_workflow.png)
![Executive Alert Output](executive_alerts_output.png)

### 📈 Business Impact & ROI Summary
* **100% Elimination of Manual Monitoring:** Replaces ~45 minutes of daily dashboard auditing (~195 hours saved annually per analyst).
* **Zero-Latency Churn Intervention:** Cuts risk detection time from days to automated morning alerts, directly protecting **$6,900/month ($82,800 ARR)** in simulated at-risk enterprise accounts.
* **Zero Custom Maintenance Overhead:** Built purely with production SQL, cloud database hosting, and Make.com orchestration—no brittle Python cron jobs to maintain.
