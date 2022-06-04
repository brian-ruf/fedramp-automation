<?xml version="1.0" encoding="utf-8"?>
<?xml-model schematypens="http://purl.oclc.org/dsdl/schematron" href="../styleguides/sch.sch" phase="basic" title="Schematron Style Guide for FedRAMP Validations" ?>
<sch:schema 
    queryBinding="xslt2"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
    xmlns:feddoc="http://us.gov/documentation/federal-documentation"
    xmlns:fedramp="https://fedramp.gov/ns/oscal"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
    xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:unit="http://us.gov/testing/unit-testing">

    <sch:ns
        prefix="oscal"
        uri="http://csrc.nist.gov/ns/oscal/1.0" />
    <sch:ns
        prefix="fedramp"
        uri="https://fedramp.gov/ns/oscal" />
    <sch:ns
        prefix="array"
        uri="http://www.w3.org/2005/xpath-functions/array" />
    <sch:ns
        prefix="map"
        uri="http://www.w3.org/2005/xpath-functions/map" />
    <sch:ns
        prefix="unit"
        uri="http://us.gov/testing/unit-testing" />

    <doc:xspec
        href="../test/rules/poam.xspec" />

    <sch:title>FedRAMP Plan of Action and Milestones Validations</sch:title>

    <sch:pattern>

        <!-- sanity checks -->

        <sch:rule
            context="/">

            <sch:report
                role="information"
                test="false() (: until global debug variable :)">This document has a "<sch:value-of
                    select="namespace-uri(/*)" />" namespace.</sch:report>
            <sch:assert
                diagnostics="document-is-OSCAL-document-diagnostic"
                id="document-is-OSCAL-document"
                role="fatal"
                test="namespace-uri(/*) eq 'http://csrc.nist.gov/ns/oscal/1.0'">This document is an OSCAL 1.0 document.</sch:assert>

            <sch:report
                role="information"
                test="false() (: until global debug variable :)">This document is a <sch:value-of
                    select="local-name(/*)" />.</sch:report>
            <sch:assert
                diagnostics="document-is-plan-of-action-and-milestones-diagnostic"
                id="document-is-plan-of-action-and-milestones"
                role="fatal"
                test="*:plan-of-action-and-milestones">This document is a plan-of-action-and-milestones.</sch:assert>

        </sch:rule>

    </sch:pattern>

    <sch:pattern
        id="import-ssp">

        <sch:rule
            context="oscal:plan-of-action-and-milestones">

            <sch:assert
                diagnostics="has-import-ssp-diagnostic"
                doc:guide-reference="Guide to OSCAL-based FedRAMP Plan of Action and Milestones (POA&amp;M) §3.5"
                id="has-import-ssp"
                role="error"
                test="oscal:import-ssp">An OSCAL POA&amp;M must have an import-ssp element.</sch:assert>

        </sch:rule>

        <sch:rule
            context="oscal:import-ssp">

            <sch:assert
                diagnostics="has-import-ssp-href-diagnostic"
                doc:guide-reference="Guide to OSCAL-based FedRAMP Plan of Action and Milestones (POA&amp;M) §3.5"
                id="has-import-ssp-href"
                role="error"
                test="exists(@href)">An OSCAL POA&amp;M import-ssp element must have an href attribute.</sch:assert>

            <sch:assert
                diagnostics="has-import-ssp-internal-href-diagnostic"
                doc:guide-reference="Guide to OSCAL-based FedRAMP Plan of Action and Milestones (POA&amp;M) §3.5"
                id="has-import-ssp-internal-href"
                role="error"
                test="
                    if (: this is a relative reference :) (matches(@href, '^#'))
                    then
                        (: the reference must exist within the document :)
                        exists(//oscal:resource[@uuid eq substring-after(current()/@href, '#')])
                    else
                        (: the assertion succeeds :)
                        true()">An OSCAL POA&amp;M import-ssp element href attribute which is document-relative must identify a target
                within the document. <sch:value-of
                    select="@href" />.</sch:assert>

            <sch:let
                name="import-ssp-url"
                value="resolve-uri(@href, base-uri())" />

            <sch:assert
                diagnostics="has-import-ssp-external-href-diagnostic"
                doc:guide-reference="Guide to OSCAL-based FedRAMP Plan of Action and Milestones (POA&amp;M) §3.5"
                id="has-import-ssp-external-href"
                role="error"
                test="
                    if (: this is not a relative reference :) (not(starts-with(@href, '#')))
                    then
                        (: the referenced document must be available :)
                        doc-available($import-ssp-url)
                    else
                        (: the assertion succeeds :)
                        true()"
                unit:override-xspec="both">An OSCAL POA&amp;M import-ssp element href attribute which is an external reference must identify an
                available target.</sch:assert>

        </sch:rule>

        <sch:rule
            context="oscal:back-matter">

            <sch:assert
                diagnostics="has-system-security-plan-resource-diagnostic"
                doc:guide-reference="Guide to OSCAL-based FedRAMP Plan of Action and Milestones (POA&amp;M) §3.5"
                id="has-system-security-plan-resource"
                role="error"
                test="
                    if (matches(//oscal:import-ssp/@href, '^#'))
                    then
                        (: there must be a system-security-plan resource :)
                        exists(oscal:resource[oscal:prop[@name eq 'type' and @value eq 'system-security-plan']])
                    else
                        (: the assertion succeeds :)
                        true()">An OSCAL POA&amp;M which does not directly import the SSP must declare the SSP as a back-matter
                resource.</sch:assert>

        </sch:rule>

        <sch:rule
            context="oscal:resource[oscal:prop[@name = 'type' and @value eq 'system-security-plan']]">

            <sch:assert
                diagnostics="has-ssp-rlink-diagnostic"
                doc:guide-reference="Guide to OSCAL-based FedRAMP Plan of Action and Milestones (POA&amp;M) §3.5"
                id="has-ssp-rlink"
                role="error"
                test="exists(oscal:rlink) and not(exists(oscal:rlink[2]))">An OSCAL POA&amp;M with a SSP resource declaration must have one and only
                one rlink element.</sch:assert>

        </sch:rule>

        <sch:rule
            context="oscal:resource[oscal:prop[@name = 'type' and @value eq 'no-oscal-ssp']]">

            <sch:assert
                diagnostics="has-non-OSCAL-system-security-plan-resource-diagnostic"
                doc:guide-reference="Guide to OSCAL-based FedRAMP Plan of Action and Milestones (POA&amp;M) §3.5.2"
                id="has-non-OSCAL-system-security-plan-resource"
                role="warning"
                test="
                    (: always warn :)
                    false()">An OSCAL POA&amp;M which lacks an OSCAL SSP must declare a no-oscal-ssp resource.</sch:assert>

        </sch:rule>

        <sch:rule
            context="oscal:resource[oscal:prop[@name = 'type' and @value eq 'system-security-plan']]/oscal:rlink">

            <sch:assert
                diagnostics="has-acceptable-system-security-plan-rlink-media-type-diagnostic"
                doc:guide-reference="Guide to OSCAL-based FedRAMP Plan of Action and Milestones (POA&amp;M) §3.5"
                id="has-acceptable-system-security-plan-rlink-media-type"
                role="error"
                test="@media-type = ('text/xml', 'application/json')">An OSCAL POA&amp;M SSP rlink must have a 'text/xml' or 'application/json'
                media-type.</sch:assert>

            <!-- TODO: check document availability when $use-remote-resources is made common -->

        </sch:rule>

        <sch:rule
            context="oscal:resource[oscal:prop[@name = 'type' and @value eq 'system-security-plan']]/oscal:base64">

            <sch:assert
                diagnostics="has-no-base64-diagnostic"
                doc:guide-reference="Guide to OSCAL-based FedRAMP Plan of Action and Milestones (POA&amp;M) §3.5"
                id="has-no-base64"
                role="error"
                test="false()">An OSCAL POA&amp;M must not use a base64 element in a system-security-plan resource.</sch:assert>

        </sch:rule>

    </sch:pattern>

    <sch:pattern
        id="timeframe">

        <sch:rule
            context="oscal:poam-item">

            <sch:assert
                diagnostics="poam-item-has-associated-risk-diagnostic"
                doc:guide-reference="Guide to OSCAL-based FedRAMP Plan of Action and Milestones (POA&amp;M) §4.2.1"
                id="poam-item-has-associated-risk"
                role="error"
                test="exists(oscal:associated-risk)">poam-item has associated-risk.</sch:assert>

            <sch:assert
                diagnostics="poam-item-has-one-associated-risk-diagnostic"
                doc:guide-reference="Guide to OSCAL-based FedRAMP Plan of Action and Milestones (POA&amp;M) §4.2.1"
                fedramp:specific="true"
                id="poam-item-has-one-associated-risk"
                role="warning"
                test="not(oscal:associated-risk[2])">poam-item has one and only one associated-risk.</sch:assert>

            <sch:assert
                diagnostics="poam-item-has-related-observation-diagnostic"
                doc:guide-reference="Guide to OSCAL-based FedRAMP Plan of Action and Milestones (POA&amp;M) §4.2.1"
                id="poam-item-has-related-observation"
                role="error"
                test="exists(oscal:related-observation)">poam-item has related-observation.</sch:assert>

            <sch:report
                doc:guide-reference="Guide to OSCAL-based FedRAMP Plan of Action and Milestones (POA&amp;M) §4.3.1"
                role="information"
                test="true()">POA&amp;M derived completion date is <sch:value-of
                    select="max(//oscal:risk[@uuid eq current()/oscal:associated-risk/@risk-uuid]/descendant::oscal:within-date-range/@end ! xs:dateTime(.))" /></sch:report>

        </sch:rule>

        <sch:rule
            context="oscal:poam-item/oscal:associated-risk">

            <sch:assert
                diagnostics="associated-risk-has-target-diagnostic"
                id="associated-risk-has-target"
                role="error"
                test="exists(//oscal:risk[@uuid eq current()/@risk-uuid])">poam-item associated-risk references a risk in this document.</sch:assert>

            <sch:assert
                diagnostics="associated-risk-has-planned-response-diagnostic"
                id="associated-risk-has-planned-response"
                role="error"
                test="exists(//oscal:risk[@uuid eq current()/@risk-uuid]/oscal:response[@lifecycle eq 'planned'])">poam-item associated-risk
                references a risk with a planned response.</sch:assert>

        </sch:rule>

        <sch:rule
            context="oscal:poam-item/oscal:related-observation">

            <sch:assert
                diagnostics="related-observation-has-observation-diagnostic"
                id="related-observation-has-observation"
                role="error"
                test="exists(//oscal:observation[@uuid eq current()/@observation-uuid])">related-observation references an observation in this
                document.</sch:assert>

        </sch:rule>

        <sch:rule
            context="oscal:risk[@uuid = //oscal:poam-item/oscal:associated-risk/@risk-uuid]"
            see="https://github.com/18F/fedramp-automation/issues/353">
            <sch:assert
                diagnostics="risk-has-deadline-diagnostic"
                id="risk-has-deadline"
                role="error"
                see="https://github.com/18F/fedramp-automation/issues/353"
                test="exists(oscal:deadline)">A risk must have a deadline.</sch:assert>

            <sch:assert
                diagnostics="risk-has-recommendation-diagnostic"
                doc:guide-reference="Guide to OSCAL-based FedRAMP Plan of Action and Milestones (POA&amp;M) §4.3"
                id="risk-has-recommendation"
                role="error"
                test="oscal:response[@lifecycle eq 'planned']">A risk must have a recommendation response.</sch:assert>

            <sch:assert
                diagnostics="risk-has-planned-response-diagnostic"
                doc:guide-reference="Guide to OSCAL-based FedRAMP Plan of Action and Milestones (POA&amp;M) §4.3"
                id="risk-has-planned-response"
                role="error"
                test="oscal:response[@lifecycle eq 'planned']">A risk must have a planned response.</sch:assert>


            <sch:assert
                diagnostics="risk-has-milestones-diagnostic"
                id="risk-has-milestones"
                role="error"
                test="exists(oscal:response/oscal:task[@type eq 'milestone'])">A risk associated with a poam-item must have one or more milestones
                (response tasks).</sch:assert>

            <sch:report
                role="information"
                test="true()">risk <sch:value-of
                    select="@uuid" /> has <sch:value-of
                    select="(oscal:characterization/oscal:facet[@name eq 'impact'][last()]/@value)[last()]" /> impact.</sch:report>

        </sch:rule>

        <sch:rule
            context="oscal:risk/oscal:response[@lifecyle eq 'planned']">

            <sch:assert
                diagnostics="planned-response-has-milestones-diagnostic"
                doc:guide-reference="Guide to OSCAL-based FedRAMP Plan of Action and Milestones (POA&amp;M) §4.3.1"
                id="planned-response-has-milestones"
                role="error"
                test="exists(oscal:task[@type eq 'milestone'])">A planned response must have one or more milestones.</sch:assert>

        </sch:rule>

        <sch:rule
            context="oscal:risk/oscal:response[@lifecyle eq 'planned']/oscal:task (: [@type eq 'milestone'] - documentation is ambiguous :)"
            see="https://github.com/GSA/fedramp-automation-guides/issues/18">

            <sch:assert
                diagnostics="milestone-has-description-diagnostic"
                doc:guide-reference="Guide to OSCAL-based FedRAMP Plan of Action and Milestones (POA&amp;M) §4.3.1"
                id="milestone-has-description"
                role="error"
                test="oscal:description">A milestone task has a description.</sch:assert>

            <sch:assert
                diagnostics="milestone-has-timing-diagnostic"
                doc:guide-reference="Guide to OSCAL-based FedRAMP Plan of Action and Milestones (POA&amp;M) §4.3.1"
                id="milestone-has-timing"
                role="error"
                test="oscal:timing">A milestone task has a timing element.</sch:assert>

            <sch:assert
                diagnostics="milestone-has-timing-within-date-range-diagnostic"
                doc:guide-reference="Guide to OSCAL-based FedRAMP Plan of Action and Milestones (POA&amp;M) §4.3.1"
                id="milestone-has-timing-within-date-range"
                role="error"
                test="oscal:timing/oscal:within-date-range">A milestone task has a timing within-date-range element.</sch:assert>

        </sch:rule>

        <sch:rule
            context="oscal:risk[@uuid = //oscal:poam-item/oscal:associated-risk/@risk-uuid]/oscal:deadline">

            <sch:assert
                diagnostics="deadline-is-valid-datetime-diagnostic"
                id="deadline-is-valid-datetime"
                role="error"
                see="https://github.com/18F/fedramp-automation/issues/353"
                test="current() castable as xs:dateTime">Risk deadline is valid xs:dateTime().</sch:assert>

        </sch:rule>

        <sch:rule
            context="oscal:timing/oscal:on-date">

            <sch:assert
                diagnostics="on-date-date-is-valid-datetime-diagnostic"
                id="on-date-date-is-valid-datetime"
                role="error"
                test="@date castable as xs:dateTime">on-date element date is valid xs:dateTime.</sch:assert>
        </sch:rule>

        <sch:rule
            context="oscal:timing/oscal:within-date-range">

            <sch:assert
                diagnostics="within-date-range-start-is-valid-datetime-diagnostic"
                id="within-date-range-start-is-valid-datetime"
                role="error"
                test="@start castable as xs:dateTime">within-date-range start is valid xs:dateTime.</sch:assert>

            <sch:assert
                diagnostics="within-date-range-end-is-valid-datetime-diagnostic"
                id="within-date-range-end-is-valid-datetime"
                role="error"
                test="@end castable as xs:dateTime">within-date-range end is valid xs:dateTime.</sch:assert>

            <sch:assert
                diagnostics="within-date-range-start-precedes-end-diagnostic"
                id="within-date-range-start-precedes-end"
                role="error"
                test="xs:dateTime(@start) le xs:dateTime(@end)">within-date-range start precedes end.</sch:assert>

        </sch:rule>

        <sch:rule
            context="oscal:timing/oscal:at-frequency">
            <!-- TODO: nothing here yet -->
        </sch:rule>

    </sch:pattern>

    <sch:diagnostics>

        <!-- sanity checks -->

        <sch:diagnostic
            id="document-is-OSCAL-document-diagnostic">This document is NOT an OSCAL 1.0 document.</sch:diagnostic>

        <sch:diagnostic
            id="document-is-plan-of-action-and-milestones-diagnostic">This document is NOT a plan-of-action-and-milestones.</sch:diagnostic>

        <!-- import-ssp -->

        <sch:diagnostic
            doc:assert="has-import-ssp"
            doc:context="oscal:assessment-plan"
            id="has-import-ssp-diagnostic">This OSCAL POA&amp;M lacks an import-ssp element.</sch:diagnostic>

        <sch:diagnostic
            doc:assert="has-import-ssp-href"
            doc:context="oscal:import-ssp"
            id="has-import-ssp-href-diagnostic">This OSCAL POA&amp;M import-ssp element lacks an href attribute.</sch:diagnostic>

        <sch:diagnostic
            doc:assert="has-import-ssp-internal-href"
            doc:context="oscal:import-ssp"
            id="has-import-ssp-internal-href-diagnostic">This OSCAL POA&amp;M import-ssp element href attribute which is document-relative does not
            identify a target within the document.</sch:diagnostic>

        <sch:diagnostic
            doc:assert="has-import-ssp-external-href"
            doc:context="oscal:import-ssp"
            id="has-import-ssp-external-href-diagnostic">This OSCAL POA&amp;M import-ssp element href attribute which is an external reference does
            not identify an available target.</sch:diagnostic>

        <sch:diagnostic
            doc:assert="has-system-security-plan-resource"
            doc:context="oscal:back-matter"
            id="has-system-security-plan-resource-diagnostic">This OSCAL POA&amp;M which does not directly import the SSP does not declare the SSP as
            a back-matter resource.</sch:diagnostic>

        <sch:diagnostic
            doc:assert="has-ssp-rlink"
            doc:context="oscal:resource[oscal:prop[@name = 'type' and @value eq 'system-security-plan']]"
            id="has-ssp-rlink-diagnostic">This OSCAL POA&amp;M with a SSP resource declaration does not have one and only one rlink
            element.</sch:diagnostic>

        <sch:diagnostic
            doc:assert="has-non-OSCAL-system-security-plan-resource"
            doc:context="oscal:resource[oscal:prop[@name = 'type' and @value eq 'no-oscal-ssp]]"
            id="has-non-OSCAL-system-security-plan-resource-diagnostic">This OSCAL POA&amp;M has a non-OSCAL SSP.</sch:diagnostic>

        <sch:diagnostic
            doc:assert="has-acceptable-system-security-plan-rlink-media-type"
            doc:context="oscal:resource[oscal:prop[@name = 'type' and @value eq 'system-security-plan']]/oscal:rlink"
            id="has-acceptable-system-security-plan-rlink-media-type-diagnostic">This OSCAL POA&amp;M SSP rlink does not have a 'text/xml' or
            'application/json' media-type.</sch:diagnostic>

        <sch:diagnostic
            doc:assert="has-no-base64"
            doc:context="oscal:resource[oscal:prop[@name = 'type' and @value eq 'system-security-plan']]/oscal:base64"
            id="has-no-base64-diagnostic">This OSCAL POA&amp;M has a base64 element in a system-security-plan resource.</sch:diagnostic>

        <!-- timeframe -->

        <sch:diagnostic
            id="poam-item-has-associated-risk-diagnostic">This poam-item lacks associated-risk.</sch:diagnostic>

        <sch:diagnostic
            id="poam-item-has-one-associated-risk-diagnostic">This poam-item has more than one associated-risk.</sch:diagnostic>

        <sch:diagnostic
            id="poam-item-has-related-observation-diagnostic">This poam-item lacks related-observation.</sch:diagnostic>

        <sch:diagnostic
            id="associated-risk-has-target-diagnostic">This associated-risk does not reference a risk in this document.</sch:diagnostic>

        <sch:diagnostic
            id="associated-risk-has-planned-response-diagnostic">This associated-risk references a risk without a planned response.</sch:diagnostic>

        <sch:diagnostic
            id="related-observation-has-observation-diagnostic">This related-observation does not reference an observation in this
            document.</sch:diagnostic>

        <sch:diagnostic
            id="risk-has-deadline-diagnostic">This risk lacks a deadline.</sch:diagnostic>

        <sch:diagnostic
            id="risk-has-planned-response-diagnostic">This risk has no planned response.</sch:diagnostic>

        <sch:diagnostic
            id="risk-has-recommendation-diagnostic">This risk has no recommendation response.</sch:diagnostic>

        <sch:diagnostic
            id="risk-has-milestones-diagnostic">This risk associated with a poam-item lacks one or more milestones (response tasks).</sch:diagnostic>

        <sch:diagnostic
            id="deadline-is-valid-datetime-diagnostic">This risk deadline is not a valid xs:dateTime().</sch:diagnostic>

        <sch:diagnostic
            id="on-date-date-is-valid-datetime-diagnostic">on-date element date is not a valid xs:dateTime.</sch:diagnostic>

        <sch:diagnostic
            id="within-date-range-start-is-valid-datetime-diagnostic">within-date-range start is not a valid xs:dateTime.</sch:diagnostic>

        <sch:diagnostic
            id="within-date-range-end-is-valid-datetime-diagnostic">within-date-range end is not a valid xs:dateTime.</sch:diagnostic>

        <sch:diagnostic
            id="within-date-range-start-precedes-end-diagnostic">within-date-range start does not precede end.</sch:diagnostic>

        <sch:diagnostic
            id="planned-response-has-milestones-diagnostic">This planned response lacks one or more milestones.</sch:diagnostic>

        <sch:diagnostic
            id="milestone-has-description-diagnostic">This milestone task lacks a description.</sch:diagnostic>

        <sch:diagnostic
            id="milestone-has-timing-diagnostic">A milestone task lacks a timing element.</sch:diagnostic>

        <sch:diagnostic
            id="milestone-has-timing-within-date-range-diagnostic">This milestone task lacks a timing within-date-range element.</sch:diagnostic>

    </sch:diagnostics>
</sch:schema>
