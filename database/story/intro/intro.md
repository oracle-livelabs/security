# Introduction

## About this Workshop
This workshop is a hands-on lab dedicated to the features and functionality of Oracle Database security to prevent, detect and mitigate the most common cyberattacks performed on Oracle Databases - for more details on each of the featured products, please refer to the DB Security livelabs.

In this lab, we will use a ransomware attack to explore how attackers operate and what database features you should use to prevent, detect, and mitigate data exfiltration risks.

A typical ransomware attack includes theft and exfiltration of data. The theft usually happens before encrypting your system to make it inoperable, with the stolen data used by the ransomware gang to help influence you to pay the ransom.

![Ransomware Attack message](./images/intro-hack-01.png "Ransomware Attack message")

In order to make this possible, we provide you with the necessary infrastructure components based on an OCI architecture, deployed in a few minutes, so that you can test the most common attacks exploited on a database by hackers with a simple internet connection.

As all these components are stored in the workshop's DBSec-Lab VM, you can conduct your attack without any risk and without fear of breaking anything to test database security use cases in an environment pre-configured by the Oracle Database Security Product Manager Team.

*Estimated Time*: 40 minutes

> If you are unfamiliar with ransomware, please take a moment to read the "Learn More" section below

### About this Product/Technology
During this lab you will use the following resources:
  - SSH Terminal Client
  - Oracle Databases
  - Glassfish HR App
  - Audit Vault web console
  - OEM Cloud Control (DBA Web console)

Note that the Glassfish HR application is a fictitious employee management web application that points to an unsecured Oracle Database named PDB1.
In our scenario, this database contains sensitive data that could be used by the attackers to extort a ransomware payment, or be sold on the dark web for profit.

As your attack protocol progresses, you will test the same commands from the same interfaces, but this time pointing to another Oracle Database named PDB2. Oracle's recommended security controls protect PDB2. You will see how a well-configured database can block the most common attacks used to break in and steal data.

*Versions tested in this lab:* Oracle DB EE 19.23, OEM 13.5, AVDF 20.13 an OKV 21.9

### Objectives
This lab helps you learn to use some of the most important security features of the Oracle Database.

You will learn how to:
- Prevent, detect and mitigate data exfiltration
- Prevent and detect privileges escalation and abuse
- Prevent and mitigate exploitation of vulnerabilities

### Prerequisites
This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account - Please view this workshop's LiveLabs landing page to see which environments are supported

- So that your experience of this workshop is the best possible, DO NOT FORGET to perform "Lab: *Initialize Environment*" to be sure that all these resources are correctly set up!

The entire Database Security team wishes you an excellent workshop!

You may now proceed to the next lab.

## Learn More
Before starting, let us explain why we chose to use a **ransomware attack** as an example to demonstrate Oracle's database security capabilities.

Cybercriminals are becoming more and more equipped and better prepared. They now have a substantial technological arsenal that allows them to launch attacks against you from almost everywhere if you are not prepared to deal with them.

Understanding the attacker's motivation and how to prevent them from being able to use the stolen data against you helps you better survive the attack and makes it more feasible to NOT pay the ransom.

Ransomware is one of the main threats in the world today according to a recent [ENISA report](https://www.enisa.europa.eu/topics/cyber-threats/threat-landscape) (the number of attacks is increasing every day, and all sectors are affected without exception). Ransomware has evolved from its beginnings to become the preferred attack to steal a company's sensitive data.

Early ransomware attacks primarily interrupted and blocked a company's activity. As late as 2019, NIST defined ransomware as "**a type of malicious attack where the attackers encrypt the organization's data and demand payment to restore access**". Encrypting data and withholding the encryption key was a prelude to a demand for payment!

From then on, the only options available to you were :
- **pay the ransom** to hope to eventually obtain the decryption key and thus recover your data… but with no guarantee that it will work, or even that the attackers will not try again later.
- **don't pay the ransom** and restore your system from your backups… hoping that the backups are still physically available, consistent and restorable quickly enough to preserve your business.

If you were not prepared for this eventuality and hadn't anticipated having to deal with it, then the disruption this type of attack posed to your business was quite a challenge to overcome. Seeing this message below probably placed you in a state of extreme stress!

![Ransomware screen](./images/intro-hack-02.png "Ransomware screen")

Ransomware evolved quickly. According to [MS-ISAC in 2020](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&ved=2ahUKEwjAo9Wi_fX3AhUG_IUKHVTIDcUQFnoECBUQAQ&url=https%3A%2F%2Fwww.cisa.gov%2Fsites%2Fdefault%2Ffiles%2Fpublications%2FCISA_MS-ISAC_Ransomware%2520Guide_S508C.pdf&usg=AOvVaw1T7xwLzdEx9zlCoNSNytU0), "malicious actors have adjusted their ransomware tactics over time to include pressuring victims to pay by threatening to release stolen data if they refuse to pay and publicly naming and shaming victims as secondary forms of extortion."

In other words, before encrypting your system to make it unavailable, the attackers steal your sensitive data and are ready to leak and sell it if you refuse to pay the ransom! The thieves modified their tactics to make it more likely you would pay the ransom instead of just recovering from backup. There are several techniques the thieves use to steal the data, as seen below.

![Attack surface of a database](./images/intro-hack-03.png "Attack surface of a database")

Fortunately for you, the Oracle Database is the best-equipped database on the market for the prevention, detection, and analysis of cyber threats.

### To go further: The stages of a ransomware attack
Several steps characterize a cyber-attack, and attackers typically follow them in the same order.

Ransomware is big business – in terms of income, it may be big enough to include in the Global 100! Modern ransomware gangs are professionally organized and operationally siloed. Specialized groups become experts at specific stages of the ransomware process. These groups sell their services or the results of their misdeeds to other groups that either don't have the specialized skills or want to save time – scaling up just like any other big business does. This agile approach offers ransomware gangs a greater capacity for generating revenue with a lower cost of operations while limiting the risk of being caught and prosecuted.

![The stages of an attack](./images/intro-hack-04.png "The stages of an attack")

#### **Step 1-5: The calm before the storm**
The first four stages of a cyberattack can happen without you seeing it coming because these attacks target systems where they are most vulnerable, often starting with users. For example, attackers target a company's staff using social networks to infiltrate the target system by sending out phishing email attacks, setting up malicious websites, sending fake software upgrade alerts, offering infected USB drives, etc (**1 - Reconnaissance**) and work to get them to click on a link, download a file, watch a video or any other action (**2 - Weaponization**) that allows attackers to download a small package of malware (exploit kit) on a system on the company's network (**3 - Delivery**) to exploit existing vulnerabilities onto the system to get a better foothold (**4 - Exploitation**). Once the malware infiltrates your system, the malicious code will set up a backdoor - a communication line back allowing a persistent access to the attacker (**5 - Installation**). At this point, the malware may lay hidden and dormant for days, weeks, or months before the attacker chooses to initiate the attack or sell this backdoor to another attacker!

Raising awareness and training staff on these risks is essential to combat these first phases. Your people should understand best practices for staying safe, especially on social networks. On a technical level, the company should equip itself with web application firewalls, anti-spam, anti-virus, and intrusion detection systems. Periodic penetration tests and security audits will also be of great help.

#### **Step 6: The wind rises**
Once attackers have a beachhead within your network, they activate a backdoor to prepare for the actual attack by communicating remotely with the exploit kit which will provide them a "hands-on keyboard access" inside the target's network (**6 - Command and Control (C2)**).

Here, they begin to spread out and attack other systems to establish multiple backdoors and scan the network to discover the golden assets to steal (**6a - Lateral movement**). One of the highest value systems to attack is your corporate directory (usually Microsoft Active Directory) and the DNS server. Successful penetration of these two systems leads to the ability to penetrate many other systems.

Thus, they can start mapping the architecture of the system they have in front of them, discovering which servers are of great use to them, which ones they will have to compromise and which ones they will have to avoid. They will, of course, try to identify new vulnerabilities, and they will do everything they can to elevate their privileges (**6b - Privilege Escalation**) by harvesting or stealing credentials. This phase can be very time-consuming, but is crucial for the final success of the attack. To give themselves enough time to spread widely throughout the organization, attackers try to avoid being spotted by working smartly under the radar.

At each stage of the attack you may see a hand-off between different groups of attackers, as one specialized group sells their results to another group that takes the attack further.

#### **Step 7: In the middle of the storm**
Now, the attackers know the targeted system, have the right tools, and have enough privileges to act, so everything is in place to accomplish their mission and the real attack can begin. That attack can happen anytime the attacker chooses and catch your organization entirely off guard (**7 - Action on objectives**). Once the attack has started, it can be a race against time for your organization to even identify that the attack is occurring so that mitigation and recovery efforts may go into action.

Once an attack is launched, your system and data are at risk. Without a mitigation and recovery plan, your sensitive data can be altered or disclosed, and downtime on your systems can range from days to months. In most cases, some data is never restored. The results of a ransomware attack are costly and can be catastrophic, both to your bottom line and to your brand reputation.

Expect attackers to go after your databases. Databases are repositories of large amounts of sensitive data, stored in systems that are specifically DESIGNED to facilitate their exploitation and analysis! Why should an attacker waste energy stealing information from hundreds of files on several servers if they can break into a database and exfiltrate millions of records in a single query (**7a - Data Exfiltration**)? Today, some hackers have specialized in data exfiltration, with strong database skills, and sell their services for targeted attacks to other criminal groups who don't have these skills.

There are several ways to exfiltrate sensitive data:
- in transit by sniffing network traffic
- at rest, directly from disk (datafiles, export or backup files) by bypassing database access controls
- from a duplicate database such as the non-production databases
- from the application using an SQL injection attack, for example
- from the production database by exploiting a vulnerability, a bad setting, etc or by compromising valid use credentials

Once the data is collected, the attackers send it back to the Command and Control (C2) servers, usually slowly, over an HTTPS tunnel to a dedicated platform on the Dark Net ready to be sold. To your perimeter defenses, it looks like someone browsing a website protected with SSL.

This is it, your data is now outside of your firewall being used for who-knows-what purpose and now, the attackers will encrypt your systems, including backups, and demand a ransom (**7b - Deploy Ransomware**)! If you don't want to pay, they will send you a sample of the data they exfiltrated to pressure you into paying by threatening to make it public.

Unfortunately, whether you pay the ransom or not, your sensitive data is now out there, and the likelihood of it being leaked or resold is still very high. It's too late because "the toothpaste can't fit in the tube anymore"!

**So, take the steps we will discuss in this lab to secure your sensitive data and avoid data theft. That way you won’t find yourself dealing with these issues AFTER you’ve been attacked**.

## Acknowledgements
- **Author** - Hakim Loumi, Database Security Senior Principal PM
- **Contributors** - Russ Lowenthal, Database Security VP
- **Last Updated By/Date** - Ethan Shmargad, Database Security PM - March 2025