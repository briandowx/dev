<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ETO_CSAT_Email_Alert</fullName>
        <description>ETO CSAT Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>briandowx@yahoo.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Goaling_Templates/ETO_CSAT_Survey</template>
    </alerts>
    <rules>
        <fullName>ETO CSAT Survey</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Closed - Converted</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>ETO_CSAT_Email_Alert</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Customer_CSAT_Survey_Sent</name>
                <type>Task</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <tasks>
        <fullName>Customer_CSAT_Survey_Sent</fullName>
        <assignedToType>owner</assignedToType>
        <description>An automatically created event indicating a CSAT survey was sent to the customer.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>true</protected>
        <status>Completed</status>
        <subject>Customer CSAT Survey Sent</subject>
    </tasks>
</Workflow>
