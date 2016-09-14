<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>MillionDealAlert</fullName>
        <ccEmails>brian.do@webex.com</ccEmails>
        <description>Million Deal Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>briandowx@yahoo.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>briandowx@ymail.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SalesNewCustomerEmail</template>
    </alerts>
    <alerts>
        <fullName>x24HrRuleEmailAlert</fullName>
        <description>24Hr Rule Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Approval_EmailTemplate</template>
    </alerts>
    <fieldUpdates>
        <fullName>ActualDecisionDate</fullName>
        <field>Actual_Decision_Date__c</field>
        <formula>IF(OR(ISPICKVAL(StageName, &quot;7. Implement&quot;), ISPICKVAL(StageName, &quot;0. Downgraded&quot;)), NOW(), NULL)</formula>
        <name>Actual Decision Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>MillionDeal</fullName>
        <apiVersion>8.0</apiVersion>
        <endpointUrl>http://www.salesforce.com</endpointUrl>
        <fields>AccountId</fields>
        <fields>Amount</fields>
        <fields>ExpectedRevenue</fields>
        <fields>Id</fields>
        <fields>Name</fields>
        <fields>Probability</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>briandowx@yahoo.com</integrationUser>
        <name>Million Deal</name>
        <protected>true</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>24Hr Respond Rule</fullName>
        <actions>
            <name>x24HrRuleEmailAlert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send an email alert to assigned Rep to follow up</description>
        <formula>ISNULL(cxLast_Activity_Date__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Actual Decision Date</fullName>
        <actions>
            <name>ActualDecisionDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>7. Implement</value>
        </criteriaItems>
        <description>Set Actual Decision Date when an opportunity is at Implementation stage.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Million Deal</fullName>
        <actions>
            <name>MillionDealAlert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterOrEqual</operation>
            <value>1000000</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
