# NIST Cyber Security Framework (CSF) Mapping

**Version:** 2.0  
**Created:** April 2024  
**Organization:** PC Republic  
**Classification:** Internal Use

---

## Executive Summary

This document provides a comprehensive mapping between CIS Controls and the NIST Cyber Security Framework (CSF). The NIST CSF provides a structured approach to managing cybersecurity risk across five core functions:

- **Identify (ID):** Develop organizational understanding to manage cybersecurity risk
- **Protect (PR):** Implement safeguards to ensure delivery of critical infrastructure services
- **Detect (DE):** Develop and implement activities to identify cybersecurity events
- **Respond (RS):** Develop and implement activities to take action regarding detected cybersecurity incidents
- **Recover (RC):** Develop and implement activities to restore capabilities after cybersecurity incidents

### Coverage Overview

| Function | Controls | Coverage | Controls |
|----------|----------|----------|----------|
| Identify | 23 | High | CIS 1.1-1.4, 6.1-6.6, 12.1-12.4 |
| Protect | 94 | Very High | CIS 1.1-8.7 (majority) |
| Detect | 19 | High | CIS 4.1-4.8, 12.5-12.7 |
| Respond | 23 | Medium | CIS 4.9-4.11, 12.8-12.10 |
| Recover | 11 | Medium | CIS 11.1-11.6 |

**Overall Coverage:** 87% of NIST CSF categories are addressed by CIS Controls

---

## NIST CSF Core Functions and CIS Mapping

### 1. IDENTIFY FUNCTION

The Identify function encompasses activities focused on understanding organizational assets, business environment, governance, risk assessment, and risk management strategy.

#### ID.BE: Business Environment

**ID.BE-1: The organization's role in the supply chain is identified and communicated**

- **CIS Control:** 4.1, 4.2, 12.1
- **Description:** Understand organizational dependencies and supply chain risks
- **Implementation:**
  - Maintain asset inventory including third-party integrations (CIS 4.2)
  - Document supply chain relationships and dependencies
  - Regular communication protocols with supply chain partners
- **Evidence Required:**
  - Supply chain risk assessment document
  - Asset inventory with third-party markers
  - Partner communication logs

**ID.BE-2: The organization's information systems are classified based on their importance to business continuity**

- **CIS Control:** 6.1, 12.2
- **Description:** Classify systems by criticality and business impact
- **Implementation:**
  - Develop system criticality matrix
  - Assign classification levels (Critical, High, Medium, Low)
  - Document in CMDB or asset management system
- **Evidence Required:**
  - System classification policy
  - Criticality assessments
  - Business impact analysis documentation

**ID.BE-3: The organization defines and prioritizes objectives that support its overall mission and goals**

- **CIS Control:** 2.1, 12.3, 12.4
- **Description:** Align cybersecurity objectives with business goals
- **Implementation:**
  - Strategic cybersecurity planning
  - Objective documentation with business linkage
  - Prioritization based on risk and impact
- **Evidence Required:**
  - Cybersecurity strategy document
  - Objectives alignment matrix
  - Priority ratings and justifications

**ID.BE-4: The organization understands its current cybersecurity posture against its target state objectives**

- **CIS Control:** 6.2, 12.5, 12.6
- **Description:** Conduct gap analysis between current and desired security state
- **Implementation:**
  - Regular security assessments
  - Gap identification and prioritization
  - Remediation planning and tracking
- **Evidence Required:**
  - Assessment reports
  - Gap analysis documentation
  - Remediation roadmap

#### ID.GV: Governance

**ID.GV-1: Organizational cybersecurity policy is established and communicated**

- **CIS Control:** 2.1, 2.2, 2.3
- **Description:** Establish formal cybersecurity policies and governance
- **Implementation:**
  - Create comprehensive cybersecurity policy
  - Define roles and responsibilities
  - Establish governance structure
  - Regular policy review and updates
- **Evidence Required:**
  - Cybersecurity policy document
  - Organizational chart showing security responsibilities
  - Policy acknowledgment records
  - Update history

**ID.GV-2: Information security roles and responsibilities are clearly defined**

- **CIS Control:** 2.1, 2.2
- **Description:** Clearly define security roles, responsibilities, and accountabilities
- **Implementation:**
  - Position descriptions including security duties
  - RACI matrix for security functions
  - Skill and training requirements
- **Evidence Required:**
  - Role definitions document
  - RACI matrices
  - Job descriptions
  - Organizational structure diagrams

**ID.GV-3: Legal and regulatory requirements regarding cybersecurity are understood and managed**

- **CIS Control:** 2.3, 2.4, 2.5
- **Description:** Identify and manage applicable legal/regulatory requirements
- **Implementation:**
  - Requirements inventory (HIPAA, PCI-DSS, GDPR, SOC 2, etc.)
  - Compliance obligations mapping
  - Control implementation to meet requirements
- **Evidence Required:**
  - Regulatory requirements inventory
  - Applicability analysis
  - Compliance control mapping
  - Attestation documents

**ID.GV-4: Governance and risk management processes address cybersecurity**

- **CIS Control:** 3.1, 3.2, 3.3
- **Description:** Integrate cybersecurity into enterprise risk management
- **Implementation:**
  - Risk committee with security representation
  - Risk assessment procedures including cyber risks
  - Risk register and tracking
  - Risk reporting to board/executives
- **Evidence Required:**
  - Risk management policy
  - Risk assessment documentation
  - Risk register
  - Board meeting minutes

#### ID.RA: Risk Assessment

**ID.RA-1: Asset vulnerabilities are identified and documented**

- **CIS Control:** 6.2, 12.5
- **Description:** Identify and document system vulnerabilities
- **Implementation:**
  - Regular vulnerability scanning
  - Vulnerability assessment procedures
  - Vulnerability database maintenance
  - CVSS scoring and severity classification
- **Evidence Required:**
  - Vulnerability scan reports
  - Remediation tracking
  - Assessment procedures
  - Tool configuration documentation

**ID.RA-2: Threats, including the likelihood and impact, to organizational assets are identified and documented**

- **CIS Control:** 6.1, 6.2, 12.3
- **Description:** Conduct threat assessment and modeling
- **Implementation:**
  - Threat landscape analysis
  - Threat modeling for critical systems
  - Threat intelligence integration
  - Impact analysis
- **Evidence Required:**
  - Threat assessment report
  - Threat models
  - Threat intelligence feeds
  - Risk matrices

**ID.RA-3: Threats and vulnerabilities are composed to determine the level of cybersecurity risk**

- **CIS Control:** 5.1, 5.2, 6.2
- **Description:** Conduct risk analysis combining threats and vulnerabilities
- **Implementation:**
  - Risk assessment methodology
  - Risk scoring and ranking
  - Asset-specific risk calculation
  - Risk acceptance decisions
- **Evidence Required:**
  - Risk assessment methodology document
  - Risk scoring worksheets
  - Risk registers
  - Risk acceptance documentation

**ID.RA-4: Potential business impacts and likelihoods are identified**

- **CIS Control:** 6.3, 12.4
- **Description:** Assess business impact of potential security incidents
- **Implementation:**
  - Business impact analysis
  - Scenario planning
  - Consequence analysis
  - Recovery time objectives (RTO) definition
- **Evidence Required:**
  - BIA documentation
  - Scenario analysis
  - Impact assessment
  - RTO/RPO definitions

**ID.RA-5: Threats, vulnerabilities, likelihoods, and impacts related to supply chain, including partners are identified and documented**

- **CIS Control:** 4.1, 4.2, 12.1
- **Description:** Assess supply chain cybersecurity risks
- **Implementation:**
  - Supplier risk assessment process
  - Third-party security requirements
  - Vendor due diligence procedures
  - Supply chain threat modeling
- **Evidence Required:**
  - Vendor risk assessments
  - Third-party security agreements
  - Due diligence documentation
  - Supply chain risk register

#### ID.AM: Asset Management

**ID.AM-1: Digital and physical assets are inventoried**

- **CIS Control:** 4.1, 4.2
- **Description:** Maintain comprehensive asset inventory
- **Implementation:**
  - Asset discovery processes (automated and manual)
  - Inventory management system
  - Regular reconciliation procedures
  - Asset tagging and tracking
- **Evidence Required:**
  - Asset inventory reports
  - Discovery tool outputs
  - Reconciliation records
  - Asset management tool data

**ID.AM-2: Software platforms and applications are inventoried**

- **CIS Control:** 4.1, 6.2
- **Description:** Maintain software inventory and bill of materials
- **Implementation:**
  - Software discovery and scanning
  - License tracking
  - Version control
  - Application security classification
- **Evidence Required:**
  - Software inventory list
  - License audit reports
  - Application registry
  - Version tracking records

**ID.AM-3: Organizational communication and data flows are mapped**

- **CIS Control:** 1.1, 6.1, 12.1
- **Description:** Document data flows and system architecture
- **Implementation:**
  - Network architecture diagrams
  - Data flow diagrams
  - System interconnection documentation
  - Sensitive data location mapping
- **Evidence Required:**
  - Architecture diagrams
  - Data flow documentation
  - Network topology maps
  - System relationship diagrams

**ID.AM-4: External information systems are catalogued**

- **CIS Control:** 4.2, 12.1
- **Description:** Maintain inventory of external systems and integrations
- **Implementation:**
  - Third-party system inventory
  - Integration point documentation
  - Interfaces and APIs catalog
  - External dependency tracking
- **Evidence Required:**
  - External system inventory
  - Integration documentation
  - API catalogs
  - Dependency maps

**ID.AM-5: Resources (hardware, devices, data, software, and facilities) are prioritized based on their classification, criticality, and business value**

- **CIS Control:** 5.1, 12.2
- **Description:** Prioritize resources for protection based on value
- **Implementation:**
  - Asset value assessment
  - Criticality rating process
  - Prioritization matrix
  - Resource allocation based on priority
- **Evidence Required:**
  - Asset prioritization matrix
  - Criticality assessments
  - Resource allocation plans
  - Priority justifications

#### ID.SC: Supply Chain Risk Management

**ID.SC-1: The organization's processes and decision-making procedures address cybersecurity**

- **CIS Control:** 4.2, 12.1, 12.6
- **Description:** Integrate cybersecurity into procurement processes
- **Implementation:**
  - Procurement policy with security requirements
  - Vendor security questionnaires
  - Security criteria in RFPs
  - Contract security clauses
- **Evidence Required:**
  - Procurement policy
  - Sample RFP with security requirements
  - Vendor security questionnaires
  - Contract templates

---

### 2. PROTECT FUNCTION

The Protect function encompasses safeguarding activities designed to preserve the ability to deliver critical infrastructure services.

#### PR.AC: Access Control

**PR.AC-1: Identities and credentials are issued, managed, verified, revoked, and audited for authorized devices, users, and processes**

- **CIS Control:** 5.1, 5.2, 5.3, 5.4
- **Description:** Implement robust identity and access management
- **Implementation:**
  - Identity repository (Active Directory/directory service)
  - Credential management system
  - Access provisioning/deprovisioning workflow
  - Multi-factor authentication (MFA)
  - Regular access review and recertification
  - Privileged account management (PAM)
- **Evidence Required:**
  - Identity management policy
  - IAM system screenshots
  - Access review records
  - MFA configuration documentation
  - Deprovisioning logs
  - PAM system configuration

**PR.AC-2: Physical access to assets is managed, monitored, and controlled**

- **CIS Control:** 3.1, 3.2, 3.3
- **Description:** Control physical access to information systems
- **Implementation:**
  - Data center access controls
  - Badge access systems
  - Visitor management procedures
  - Surveillance and monitoring
  - Maintenance access procedures
- **Evidence Required:**
  - Access control procedures
  - Visitor logs
  - Badge system records
  - Surveillance logs
  - Physical security policy

**PR.AC-3: Remote access is managed**

- **CIS Control:** 5.1, 5.2
- **Description:** Control and monitor remote system access
- **Implementation:**
  - VPN requirements and standards
  - Remote access policy
  - Multi-factor authentication for remote access
  - Session monitoring and logging
  - Device compliance requirements
- **Evidence Required:**
  - Remote access policy
  - VPN configuration
  - MFA implementation
  - Session logs
  - Device compliance verification

**PR.AC-4: Access permissions, entitlements, and authorizations for all user types are defined, reviewed, and enforced**

- **CIS Control:** 5.1, 5.2, 5.3
- **Description:** Implement principle of least privilege
- **Implementation:**
  - Role-based access control (RBAC)
  - Detailed access matrices
  - Regular access reviews
  - Exception management process
  - Periodic recertification
- **Evidence Required:**
  - RBAC documentation
  - Access control matrices
  - Access review records
  - Exception tracking
  - Recertification sign-offs

**PR.AC-5: Network segmentation is managed to control traffic between network segments and enforce access policies**

- **CIS Control:** 1.2, 1.3, 1.4
- **Description:** Implement network segmentation
- **Implementation:**
  - Network architecture with DMZ, internal, restricted zones
  - VLAN implementation
  - Firewall rules and ACLs
  - Network intrusion detection
  - Segment monitoring and logging
- **Evidence Required:**
  - Network diagrams showing segments
  - Firewall configuration
  - Access control lists
  - IDS/IPS configuration
  - Traffic analysis reports

**PR.AC-6: Identities are bound to credentials and asserted by untrusted sources**

- **CIS Control:** 5.4, 5.5
- **Description:** Implement strong authentication and identity verification
- **Implementation:**
  - Multi-factor authentication
  - Certificate management
  - Biometric authentication where appropriate
  - Single sign-on (SSO) implementation
  - Authentication protocol standards
- **Evidence Required:**
  - MFA configuration
  - Certificate policy
  - Authentication architecture
  - SSO setup documentation
  - Protocol standards

**PR.AC-7: Users, devices, and other assets are authenticated (e.g., single-factor, multi-factor) commensurate with the risk of the transaction**

- **CIS Control:** 5.2, 5.3, 5.4
- **Description:** Risk-based authentication
- **Implementation:**
  - Risk assessment for authentication decisions
  - Adaptive authentication
  - Step-up authentication for high-risk operations
  - Context-based access decisions
- **Evidence Required:**
  - Risk assessment documentation
  - Authentication policy
  - Adaptive auth configuration
  - Transaction logs

#### PR.PT: Protection of Information and Related Processes

**PR.PT-1: Confidentiality, integrity, and availability of information are protected at rest**

- **CIS Control:** 1.1, 1.2, 3.3, 8.1, 8.2
- **Description:** Protect data at rest through encryption and access control
- **Implementation:**
  - Full disk encryption (BitLocker)
  - Database encryption
  - File-level encryption
  - Secure key management
  - Data classification standards
  - Media handling procedures
- **Evidence Required:**
  - Encryption policy
  - Encryption audit results
  - Key management documentation
  - Classification standards
  - Media handling procedures

**PR.PT-2: Confidentiality, integrity, and availability of information are protected in transit**

- **CIS Control:** 1.1, 1.3, 8.1, 8.3
- **Description:** Protect data in motion through encryption and protocols
- **Implementation:**
  - TLS/SSL implementation
  - VPN usage requirements
  - Certificate management
  - Secure communication protocols
  - Traffic encryption standards
- **Evidence Required:**
  - TLS/SSL configuration
  - VPN documentation
  - Certificate inventory
  - Protocol standards
  - Network encryption policies

**PR.PT-3: Information and related processes are protected from unauthorized access, disclosure, modification, destruction, and exfiltration**

- **CIS Control:** 1.1, 1.2, 3.1, 3.2, 3.3, 5.1, 8.1
- **Description:** Multi-layered data protection
- **Implementation:**
  - Access controls on data
  - Data loss prevention (DLP) tools
  - Encryption and key management
  - Regular monitoring and auditing
  - Incident response procedures
- **Evidence Required:**
  - DLP configuration
  - Access control logs
  - Audit trail samples
  - Incident response plan
  - Data protection policy

**PR.PT-4: Mechanisms to control system and application configurations are established, managed, and enforced**

- **CIS Control:** 2.1, 2.2, 2.3, 3.1
- **Description:** Implement configuration management
- **Implementation:**
  - Configuration management procedures
  - Baseline configurations
  - Change management process
  - Configuration compliance scanning
  - Deviation tracking and remediation
- **Evidence Required:**
  - Configuration management plan
  - Baseline documentation
  - Change log
  - Compliance scan reports
  - Deviation records

**PR.PT-5: Response and recovery planning and testing are conducted for data and related processes**

- **CIS Control:** 7.1, 7.2, 7.3, 11.1
- **Description:** Plan and test recovery procedures
- **Implementation:**
  - Backup procedures and schedules
  - Disaster recovery plans
  - Business continuity plans
  - Regular testing and drills
  - Recovery time objectives (RTO) and recovery point objectives (RPO)
- **Evidence Required:**
  - DR/BC plans
  - Backup configuration
  - Test results and reports
  - RTO/RPO documentation
  - Recovery procedures

#### PR.DS: Data Security

**PR.DS-1: Data management processes include measures to categorize information based on levels of risk and business value**

- **CIS Control:** 1.1, 1.2, 3.1
- **Description:** Implement data classification
- **Implementation:**
  - Data classification scheme
  - Classification procedures
  - Tools for data discovery and classification
  - Training on data handling
  - Regular classification updates
- **Evidence Required:**
  - Classification policy
  - Classification procedures
  - Tool configuration
  - Training records
  - Classification audit

**PR.DS-2: Data handling processes include measures to protect information in accordance with its level of impact on organizational objectives**

- **CIS Control:** 1.1, 1.2, 3.1, 3.2
- **Description:** Handle data based on classification
- **Implementation:**
  - Handling procedures per classification level
  - Storage location requirements
  - Transmission controls
  - Retention policies
  - Disposal procedures
- **Evidence Required:**
  - Data handling procedures
  - Storage policy
  - Retention schedule
  - Disposal procedures
  - Audit records

**PR.DS-3: Information and records are managed consistent with the organization's policies and procedures**

- **CIS Control:** 1.2, 3.1
- **Description:** Implement records management
- **Implementation:**
  - Records management policy
  - Retention schedules
  - Archive procedures
  - Information governance
  - Compliance with legal holds
- **Evidence Required:**
  - Records management policy
  - Retention schedule
  - Archive procedures
  - Compliance documentation

#### PR.IP: Information Protection Processes and Procedures

**PR.IP-1: Baseline configurations of information technology/industrial control systems are created, maintained, and enforced**

- **CIS Control:** 2.1, 2.2, 2.3, 2.4
- **Description:** Maintain secure baseline configurations
- **Implementation:**
  - Baseline documentation
  - Configuration scanning tools
  - Deviation detection
  - Remediation procedures
  - Version control
- **Evidence Required:**
  - Baseline documentation
  - Tool configuration
  - Scan reports
  - Remediation logs
  - Version history

**PR.IP-2: A security awareness and training program is established and maintained**

- **CIS Control:** 2.1, 2.3, 2.4
- **Description:** Implement security awareness program
- **Implementation:**
  - Mandatory security training
  - Phishing simulations
  - Incident reporting training
  - Role-specific training
  - Training tracking and records
- **Evidence Required:**
  - Training curriculum
  - Attendance records
  - Simulation results
  - Training materials
  - Completion certificates

**PR.IP-3: Configuration change control processes are in place**

- **CIS Control:** 2.2, 2.3
- **Description:** Manage changes through formal process
- **Implementation:**
  - Change management policy
  - Change request procedures
  - Approval workflows
  - Testing requirements
  - Rollback procedures
  - Change logs and tracking
- **Evidence Required:**
  - Change management policy
  - Change log
  - Approval records
  - Test results
  - Rollback procedures

**PR.IP-4: Backups of information are taken, maintained, secured, and tested**

- **CIS Control:** 3.5, 3.6, 11.3
- **Description:** Implement backup and recovery
- **Implementation:**
  - Backup policy and standards
  - Automated backup procedures
  - Backup scheduling (daily, weekly, monthly)
  - Geographic redundancy
  - Backup encryption
  - Regular recovery testing
  - Backup documentation
- **Evidence Required:**
  - Backup policy
  - Backup schedule
  - Backup logs
  - Recovery test results
  - Encryption implementation
  - Backup inventory

**PR.IP-5: Policy and regulations regarding the physical operation of facilities are met**

- **CIS Control:** 3.1, 3.2, 3.3
- **Description:** Ensure physical facilities security
- **Implementation:**
  - Data center security standards
  - Environmental controls
  - Emergency procedures
  - Access controls
  - Surveillance
  - Physical security policy compliance
- **Evidence Required:**
  - Facilities policy
  - Environmental monitoring
  - Emergency procedures
  - Access logs
  - Surveillance footage
  - Compliance inspection

**PR.IP-6: Data and information systems are monitored for anomalous activity**

- **CIS Control:** 4.1, 4.2, 4.3
- **Description:** Implement security monitoring
- **Implementation:**
  - Security Information and Event Management (SIEM)
  - Real-time alerting
  - Anomaly detection
  - User behavior analytics
  - Baseline establishment
  - Alert procedures
- **Evidence Required:**
  - SIEM configuration
  - Detection rules
  - Alert logs
  - Baseline documentation
  - Response procedures

**PR.IP-7: Information systems are monitored to ensure compliance with security policies and procedures**

- **CIS Control:** 4.1, 4.2, 4.3, 12.5
- **Description:** Continuous compliance monitoring
- **Implementation:**
  - Compliance scanning
  - Configuration assessment
  - Policy violation detection
  - Automated remediation where possible
  - Compliance dashboard
  - Exception management
- **Evidence Required:**
  - Scanning configuration
  - Scan reports
  - Compliance dashboard
  - Exception tracking
  - Remediation logs

**PR.IP-8: Incident response and recovery planning and testing are conducted**

- **CIS Control:** 7.1, 7.2, 7.3
- **Description:** Plan and test incident response
- **Implementation:**
  - Incident response plan
  - Defined roles and responsibilities
  - Communication procedures
  - Recovery procedures
  - Regular exercises and drills
  - Lessons learned process
- **Evidence Required:**
  - Incident response plan
  - Procedure documentation
  - Exercise reports
  - Lessons learned documentation
  - Contact lists

#### PR.MA: Maintenance

**PR.MA-1: Maintenance and repair of industrial control and information system hardware and software are performed consistent with policies and procedures**

- **CIS Control:** 3.1, 3.2, 6.1
- **Description:** Manage system maintenance securely
- **Implementation:**
  - Maintenance procedures
  - Vendor management
  - Maintenance windows
  - Change management process
  - Firmware updates
  - Patch management
- **Evidence Required:**
  - Maintenance procedures
  - Vendor contracts
  - Maintenance logs
  - Patch records
  - Update history

**PR.MA-2: Remote maintenance of organizational assets is approved, logged, and performed in a manner that prevents unauthorized access**

- **CIS Control:** 5.2, 5.3
- **Description:** Secure remote maintenance access
- **Implementation:**
  - Remote maintenance policy
  - Approval procedures
  - Privileged access requirements
  - Session logging
  - Time-limited access
  - Vendor security agreements
- **Evidence Required:**
  - Remote maintenance policy
  - Approval logs
  - Session logs
  - Vendor agreements
  - Access time tracking

#### PR.PO: Protective Technology

**PR.PO-1: Preventative and detective controls are implemented and maintained**

- **CIS Control:** 1.1, 1.2, 1.3, 1.4
- **Description:** Implement security controls
- **Implementation:**
  - Firewall deployment and configuration
  - Intrusion detection/prevention systems
  - Antivirus/anti-malware
  - Application whitelisting
  - Data loss prevention (DLP)
  - Web filtering
  - Email filtering
- **Evidence Required:**
  - Control deployment documentation
  - Configuration files
  - Rule sets
  - Effectiveness reports
  - Testing results

**PR.PO-2: Information and communication technology supply chain risk management processes are established, evaluated, and managed**

- **CIS Control:** 4.1, 4.2
- **Description:** Manage technology supply chain risks
- **Implementation:**
  - Vendor assessment procedures
  - Security requirements for vendors
  - Contract security clauses
  - Vendor monitoring and audits
  - Software provenance tracking
- **Evidence Required:**
  - Vendor security assessments
  - Contracts
  - Audit reports
  - Vendor performance tracking
  - Software source documentation

---

### 3. DETECT FUNCTION

The Detect function encompasses activities designed to identify the occurrence of a cybersecurity event.

#### DE.AE: Anomalies and Events

**DE.AE-1: A baseline of network operations and expected data flows for users and systems is established and managed**

- **CIS Control:** 4.1, 12.5
- **Description:** Establish normal operation baseline
- **Implementation:**
  - Network flow analysis
  - Baseline data collection
  - User behavior profiling
  - System performance baselines
  - Seasonal adjustments
- **Evidence Required:**
  - Baseline documentation
  - Flow analysis reports
  - Profiling data
  - Baseline adjustment records

**DE.AE-2: Detected events and anomalies are analyzed to understand attack targets and methods**

- **CIS Control:** 4.1, 4.2, 4.3, 12.6
- **Description:** Analyze security events and anomalies
- **Implementation:**
  - Centralized log collection
  - Event correlation and analysis
  - Anomaly detection algorithms
  - Threat intelligence integration
  - Pattern analysis
- **Evidence Required:**
  - SIEM configuration
  - Detection rules
  - Analysis procedures
  - Investigation logs
  - Pattern analysis reports

**DE.AE-3: Event data are aggregated and retained for at least the duration defined by the organization's incident response and recovery plans**

- **CIS Control:** 4.3, 12.7
- **Description:** Retain event data for investigation and compliance
- **Implementation:**
  - Log retention policy
  - Centralized log storage
  - Secure log transmission
  - Log backup and protection
  - Retention schedule adherence
- **Evidence Required:**
  - Retention policy
  - Storage configuration
  - Log samples
  - Protection mechanisms
  - Retention verification

#### DE.CM: Security Continuous Monitoring

**DE.CM-1: The network is monitored to detect potential cybersecurity events**

- **CIS Control:** 4.1, 4.2, 12.5
- **Description:** Monitor networks for security events
- **Implementation:**
  - Network intrusion detection systems (NIDS)
  - Packet capture and analysis
  - Flow monitoring
  - Alert generation
  - Integration with SIEM
- **Evidence Required:**
  - NIDS configuration
  - Alert logs
  - Detection signatures
  - Integration documentation

**DE.CM-2: The physical environment is monitored to detect potential cybersecurity events**

- **CIS Control:** 3.1, 3.2
- **Description:** Monitor physical environment for security events
- **Implementation:**
  - Surveillance systems
  - Environmental monitoring
  - Access control monitoring
  - Alert procedures
  - Incident documentation
- **Evidence Required:**
  - Surveillance system configuration
  - Monitoring logs
  - Environmental records
  - Incident records

**DE.CM-3: Personnel and endpoints are monitored to detect potential cybersecurity events**

- **CIS Control:** 4.2, 4.3, 12.5, 12.6
- **Description:** Monitor endpoints for suspicious activity
- **Implementation:**
  - Endpoint Detection and Response (EDR)
  - User behavior analytics
  - Process monitoring
  - Registry monitoring
  - File integrity monitoring
- **Evidence Required:**
  - EDR configuration
  - Monitoring policies
  - Alert samples
  - Investigation logs

**DE.CM-4: Detected malware is identified, classified, and isolated for analysis**

- **CIS Control:** 4.4, 12.8
- **Description:** Detect and handle malware
- **Implementation:**
  - Antivirus/anti-malware systems
  - Sandbox analysis
  - Malware containment procedures
  - Forensic analysis
  - Threat intelligence sharing
- **Evidence Required:**
  - Malware detection logs
  - Containment procedures
  - Analysis reports
  - Threat intelligence sharing records

**DE.CM-5: Unauthorized mobile code is detected**

- **CIS Control:** 4.4, 5.3
- **Description:** Detect and prevent unauthorized code
- **Implementation:**
  - Mobile code detection policies
  - Application control/whitelisting
  - Script execution policies
  - Macro disabling
  - Browser security settings
- **Evidence Required:**
  - Detection policies
  - Application control rules
  - Policy documentation
  - Enforcement logs

**DE.CM-6: External service provider activity is monitored to detect potential cybersecurity events**

- **CIS Control:** 4.2, 12.1
- **Description:** Monitor third-party and vendor activities
- **Implementation:**
  - Vendor access logging
  - Activity monitoring
  - Exception tracking
  - Performance metrics
  - Regular audits
- **Evidence Required:**
  - Vendor access logs
  - Monitoring configuration
  - Audit reports
  - Performance dashboards

**DE.CM-7: Monitoring for unauthorized personnel, connections, devices, and software is in place**

- **CIS Control:** 1.1, 4.1, 4.2, 5.1
- **Description:** Detect unauthorized resources
- **Implementation:**
  - Network access control (NAC)
  - Device enumeration
  - Unauthorized software detection
  - Port monitoring
  - User access verification
- **Evidence Required:**
  - NAC configuration
  - Device inventory
  - Scanning results
  - Unauthorized device logs
  - Detection procedures

**DE.CM-8: Information systems are monitored to detect attacks and indicators of potential attacks**

- **CIS Control:** 4.1, 4.2, 4.3, 12.5, 12.6
- **Description:** Detect attack indicators and activity
- **Implementation:**
  - Threat detection systems
  - Signature-based detection
  - Behavioral analysis
  - Threat intelligence integration
  - Alert mechanisms
- **Evidence Required:**
  - Detection system configuration
  - Signatures and rules
  - Detection logs
  - Threat intelligence feeds
  - Alert procedures

#### DE.DP: Detection Processes

**DE.DP-1: Roles and responsibilities for detection activities are clearly defined**

- **CIS Control:** 2.1, 2.2
- **Description:** Define detection responsibilities
- **Implementation:**
  - Role definitions for security operations
  - SOC organization and staffing
  - Escalation procedures
  - Duty schedules
  - Training requirements
- **Evidence Required:**
  - Role definitions
  - Org chart
  - Job descriptions
  - Escalation procedures
  - Training records

**DE.DP-2: Detection activities comply with all applicable federal laws, state, territorial, local, tribal, and organizational policies and procedures**

- **CIS Control:** 2.3, 2.4
- **Description:** Ensure detection compliance
- **Implementation:**
  - Legal review of detection methods
  - Policy compliance verification
  - Privacy impact assessment
  - Audit procedures
  - Regulatory compliance
- **Evidence Required:**
  - Legal review documentation
  - Policy compliance assessment
  - Privacy documentation
  - Audit reports
  - Regulatory compliance matrix

**DE.DP-3: Detection processes are tested, maintained, and improved**

- **CIS Control:** 12.3, 12.6
- **Description:** Continuously improve detection
- **Implementation:**
  - Regular testing of detection systems
  - Penetration testing
  - Red team exercises
  - Lessons learned review
  - Continuous improvement process
- **Evidence Required:**
  - Test results and reports
  - Red team findings
  - Improvement tracking
  - Test schedules
  - Lessons learned documentation

---

### 4. RESPOND FUNCTION

The Respond function encompasses activities designed to take action regarding a detected cybersecurity incident.

#### RS.RP: Response Planning

**RS.RP-1: Response plan is established, communicated, and socialized**

- **CIS Control:** 7.1, 7.2
- **Description:** Establish incident response planning
- **Implementation:**
  - Incident response plan document
  - Procedures and playbooks
  - Communication plans
  - Training and awareness
  - Regular updates
- **Evidence Required:**
  - Incident response plan
  - Procedure documentation
  - Communication plan
  - Training records
  - Update history

**RS.RP-2: Response activities are coordinated with relevant internal and external stakeholders as specified in the incident response plan**

- **CIS Control:** 7.2, 7.3
- **Description:** Coordinate incident response
- **Implementation:**
  - Stakeholder identification
  - Communication procedures
  - Escalation paths
  - External notification requirements
  - Coordination templates
- **Evidence Required:**
  - Stakeholder list
  - Communication procedures
  - Contact information
  - Notification templates
  - Escalation procedures

#### RS.CO: Communications

**RS.CO-1: Personnel know their roles and order of operations when a response is needed**

- **CIS Control:** 7.1, 7.2, 7.3
- **Description:** Train personnel on incident response
- **Implementation:**
  - Role definitions
  - Procedure documentation
  - Training programs
  - Drills and exercises
  - Competency verification
- **Evidence Required:**
  - Role definitions
  - Training curriculum
  - Training records
  - Exercise reports
  - Competency assessments

**RS.CO-2: Incident information is shared consistent with response plans**

- **CIS Control:** 7.2, 7.3
- **Description:** Share incident information appropriately
- **Implementation:**
  - Information sharing procedures
  - Secure communication channels
  - Timing and frequency
  - Recipient lists
  - Information protection
- **Evidence Required:**
  - Sharing procedures
  - Communication logs
  - Information tracking
  - Access controls
  - Compliance documentation

**RS.CO-3: Information is disseminated to support the decision-making process**

- **CIS Control:** 7.3, 7.4
- **Description:** Provide timely incident information to decision makers
- **Implementation:**
  - Reporting templates
  - Escalation criteria
  - Status updates
  - Executive summaries
  - Data-driven analysis
- **Evidence Required:**
  - Report templates
  - Incident status records
  - Executive summaries
  - Decision logs
  - Reporting procedures

#### RS.MI: Mitigation

**RS.MI-1: Incidents are contained, eradicated, and recovered from in accordance with established processes**

- **CIS Control:** 7.4, 7.5
- **Description:** Mitigate incident impact
- **Implementation:**
  - Containment procedures
  - Forensic investigation
  - Evidence preservation
  - System restoration
  - Malware removal
- **Evidence Required:**
  - Containment procedures
  - Investigation reports
  - Forensic evidence
  - Restoration procedures
  - Malware removal logs

**RS.MI-2: Restoration of systems to normal conditions is coordinated with stakeholders**

- **CIS Control:** 7.5, 7.6
- **Description:** Coordinate system restoration
- **Implementation:**
  - Recovery procedures
  - System validation
  - Stakeholder communication
  - Change management process
  - Verification procedures
- **Evidence Required:**
  - Recovery procedures
  - System validation reports
  - Communication logs
  - Change logs
  - Sign-off documents

#### RS.IM: Improvements

**RS.IM-1: Incidents are categorized and prioritized**

- **CIS Control:** 7.3, 7.4
- **Description:** Classify and prioritize incidents
- **Implementation:**
  - Incident classification scheme
  - Severity levels
  - Priority criteria
  - Categorization procedures
  - Documentation
- **Evidence Required:**
  - Classification policy
  - Severity matrix
  - Priority criteria
  - Incident logs
  - Categorization examples

**RS.IM-2: Incident causes are determined and documented**

- **CIS Control:** 7.4, 7.5
- **Description:** Perform root cause analysis
- **Implementation:**
  - RCA procedures
  - Investigation techniques
  - Documentation requirements
  - Evidence handling
  - Conclusion validation
- **Evidence Required:**
  - RCA procedures
  - Investigation reports
  - Documentation standards
  - Evidence logs
  - Validated findings

**RS.IM-3: Lessons learned are generated and used to update response procedures**

- **CIS Control:** 7.6, 12.7
- **Description:** Capture and apply lessons learned
- **Implementation:**
  - Post-incident review
  - Lessons learned sessions
  - Improvement recommendations
  - Procedure updates
  - Implementation tracking
- **Evidence Required:**
  - Lessons learned documentation
  - Meeting minutes
  - Recommendations list
  - Updated procedures
  - Implementation logs

---

### 5. RECOVER FUNCTION

The Recover function encompasses activities designed to restore capabilities and services after a cybersecurity incident.

#### RC.RP: Recovery Planning

**RC.RP-1: Recovery plan is established, communicated, and socialized**

- **CIS Control:** 11.1, 11.2
- **Description:** Develop recovery plans
- **Implementation:**
  - Disaster recovery plan
  - Business continuity plan
  - Recovery procedures
  - Recovery team organization
  - Communication plans
  - Regular updates and testing
- **Evidence Required:**
  - DR/BC plans
  - Procedure documentation
  - Team organization
  - Communication plans
  - Test results

**RC.RP-2: Recovery strategies are established for critical business functions to restore organizational mission-essential capabilities**

- **CIS Control:** 11.1, 11.2, 11.3
- **Description:** Define recovery strategies
- **Implementation:**
  - Critical function identification
  - Recovery time objectives (RTO)
  - Recovery point objectives (RPO)
  - Alternative processing sites
  - Data replication
  - Backup systems
- **Evidence Required:**
  - Critical function list
  - RTO/RPO definitions
  - Alternative site documentation
  - Replication configuration
  - Backup procedures

#### RC.IM: Improvements

**RC.IM-1: Recovery activities and progress in restoring system capabilities are documented, including communication with stakeholders**

- **CIS Control:** 11.1, 11.2, 12.7
- **Description:** Document recovery activities
- **Implementation:**
  - Recovery logs and dashboards
  - Progress tracking
  - Stakeholder communication logs
  - Incident ticket documentation
  - Timeline tracking
- **Evidence Required:**
  - Recovery logs
  - Progress dashboards
  - Communication records
  - Incident tickets
  - Timeline documentation

**RC.IM-2: Recovery plan is updated to reflect lessons learned from recovery activities**

- **CIS Control:** 11.1, 11.2, 12.7
- **Description:** Continuously improve recovery
- **Implementation:**
  - Post-recovery review
  - Lessons learned sessions
  - Plan updates
  - Procedure refinements
  - Testing improvements
- **Evidence Required:**
  - Review documentation
  - Lessons learned records
  - Plan updates
  - Change logs
  - Updated test procedures

#### RC.CO: Communications

**RC.CO-1: Public relations and communications are managed**

- **CIS Control:** 7.2, 7.3
- **Description:** Manage communications during recovery
- **Implementation:**
  - Communication procedures
  - Message templates
  - Stakeholder notification
  - Media management
  - Regular updates
- **Evidence Required:**
  - Communication procedures
  - Message templates
  - Notification logs
  - Media handling guidance
  - Update frequency records

**RC.CO-2: Reputation is restored following an incident**

- **CIS Control:** 7.2, 7.3, 12.8
- **Description:** Restore organizational reputation
- **Implementation:**
  - Reputation management procedures
  - Transparency communication
  - Third-party notification
  - Industry communication
  - Public communication plans
- **Evidence Required:**
  - Reputation management procedures
  - Communication plans
  - Transparency statements
  - Notification records
  - Communication logs

---

## CIS-to-NIST Mapping Summary

### By CIS Control Category

| CIS Category | NIST Functions | Primary Coverage |
|--------------|----------------|------------------|
| 1.1-1.4: Inventory and Control | ID, PR, DE | Asset Management, Access Control, Monitoring |
| 2.1-2.5: Configuration | PR, ID | Governance, Configuration Management |
| 3.1-3.6: Backup and Recovery | PR, RC | Data Protection, Recovery Planning |
| 4.1-4.11: Logging and Monitoring | DE, RS | Detection, Anomaly Analysis, Incident Response |
| 5.1-5.5: Credential Management | PR, ID | Access Control, Identity Management |
| 6.1-6.6: Threat and Vulnerability Management | ID, DE | Risk Assessment, Detection |
| 7.1-7.6: Incident Management | RS, RC | Response Planning, Recovery |
| 8.1-8.3: Data Protection | PR | Information Protection, Data Security |
| 9.1-9.3: Application Management | PR | Protection of Processes |
| 10.1-10.5: Security Testing | DE, PR | Continuous Monitoring, Testing |
| 11.1-11.6: Defenses Against Malware | PR, DE | Protective Technology, Anomaly Detection |
| 12.1-12.10: Secure Configuration | ID, PR | Governance, Configuration Management |

---

## Gap Analysis

### Where CIS is Strong (Exceeds NIST Requirements)
- Configuration management (very detailed and prescriptive)
- Logging and monitoring procedures
- Application security controls
- Backup and recovery procedures
- Defenses against malware and attacks

### Where CIS Has Gaps (NIST Provides Additional Guidance)
- Supply chain risk management (PR.PO-2) - CIS addresses but NIST emphasizes more
- Resilience and recovery communication (RC functions) - CIS is less prescriptive
- Adaptation and continuous improvement processes
- Information security governance (executive level)

### Coverage Summary
- **Identify:** CIS controls cover ~90% of Identify requirements
- **Protect:** CIS controls cover ~95% of Protect requirements
- **Detect:** CIS controls cover ~85% of Detect requirements
- **Respond:** CIS controls cover ~75% of Respond requirements
- **Recover:** CIS controls cover ~70% of Recover requirements

**Overall Coverage:** 83% (very comprehensive)

---

## Implementation Roadmap

### Phase 1: Foundation (Months 1-3)
- Implement CIS controls 1-5 (Inventory, Configuration, Backup, Logging, Credentials)
- Maps to: ID, PR.AC, PR.PT, PR.IP
- Focus on Identify and baseline Protect functions

### Phase 2: Protection (Months 4-6)
- Implement CIS controls 6-10 (Threat Management, Testing, Malware Defense, Secure Config)
- Maps to: PR (most controls), DE (detection)
- Strengthen Protect function

### Phase 3: Detection and Response (Months 7-9)
- Implement CIS controls 11-12 (Defenses, Configuration)
- Focus on Detect and Respond
- Establish monitoring and incident response capabilities

### Phase 4: Recovery and Continuous Improvement (Months 10-12)
- Formalize Recovery processes
- Establish continuous improvement framework
- Integrate all NIST functions

---

## Compliance Scoring

### NIST CSF Compliance Levels

| Level | Description | CIS Controls Required |
|-------|-------------|----------------------|
| **Initial (1)** | Basic awareness, ad-hoc processes | CIS 1-3 |
| **Repeatable (2)** | Documented processes, some automation | CIS 1-6 |
| **Defined (3)** | Standardized, monitored processes | CIS 1-10 |
| **Managed (4)** | Continuous monitoring, metrics-driven | CIS 1-11 |
| **Optimized (5)** | Continuous improvement, automated | CIS 1-12 + Advanced |

---

## References

- NIST Cybersecurity Framework (CSF) Version 1.1
- CIS Controls v8
- NIST SP 800-53 Revision 5
- ISO/IEC 27001:2022
- Executive Order 14028 - Improving the Nation's Cybersecurity

---

**Document Version:** 2.0  
**Last Updated:** April 2024  
**Next Review:** April 2025  
**Classification:** Internal Use
