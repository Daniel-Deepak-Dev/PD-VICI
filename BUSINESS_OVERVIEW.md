# VICI Vision — Business & Org Overview

This document summarizes what this Salesforce org is for, based on the retrieved metadata under `force-app/main/default/`, live data queries against the production org (alias `PD_vici_prod`, `vici.my.salesforce.com`), and the company's public website.

## The company

**VICI & C S.p.A.** is an Italian manufacturer headquartered in **Santarcangelo di Romagna**, in business for roughly 49 years (founded ~1977), with 200+ employees and a network described as "40 specialist centers" worldwide, serving customers in hundreds of turning companies globally.

The group has three divisions:

- **VICIVISION** — optical, non-contact measurement machines. This is the division this Salesforce org actually serves; the CRM data model, automation, and portals below are all VICIVISION-specific.
- **VICI Automation** — quality-control solutions for automation processes.
- **VICI Electrical Panel** — industrial electrical panels.

VICIVISION's core product is **non-contact optical measurement of shafts and turned parts** (cylindrical parts — shafts, valves, spools, screws), sold to turning centers, automotive manufacturers, and medical/dental component makers. The brand **Metrios** was absorbed into VICIVISION and is now marketed as "Metrios by VICIVISION" — explaining the `METRIOS` picklist values found throughout the org. Product line codes seen in the data: **MTL**, **METRIOS**, **MTP**.

Sales happen **globally through a multi-tier dealer/reseller network**, not direct-only: Italy (North-East / North-West), Germany, Benelux, China, Korea, Romania/Bulgaria (via a "TopMetrology" partner), and a newly opened India branch.

Sources: [vici.it/en](https://vici.it/en/), [vicivision.com](https://www.vicivision.com/)

## What the Salesforce org does

The org is VICIVISION's CRM + Partner/Dealer Portal, covering the full commercial and after-sales lifecycle:

**Marketing & lead capture** → **Opportunity & quoting** → **Order/Asset delivery** → **Software license activation** → **Warranty & calibration** → **Service/repair** → **Dealer portal & marketing collateral** → **Customer satisfaction surveys** → **GDPR consent management**

### Data model

| Object | Purpose |
|---|---|
| `Asset_Vici__c` | The central hub — an installed machine, tracked by serial number ("Matricola"), with warranty/calibration dates, software version, links to dealer, billing customer vs. end-user customer, opportunity, and machine model. |
| `Modello_Macchina__c`, `Component__c`, `Articolo__c` | Machine model catalog and bill-of-materials/component structure. |
| `Contratto_dealer__c` | Formal dealer distribution agreements — territory exclusivity, discount, budget, marketing contribution, lifecycle status. |
| `Richiesta_speciale__c` | Custom machine configuration requests, with a technical-feasibility status field (no formal approval process backs it). |
| `Ricambi_Caso__c` | Spare parts billed against a service Case. |
| `AssetActivationRegisterSQLite__c` | HASP dongle software-license activation log, keyed by machine serial. |
| `Survey__c` / `Survey_Question__c` / `SurveyTaker__c` | A GSurvey/SurveyForce-derived survey engine driving product-concept and post-sale satisfaction surveys in Italian, English, and German. |
| `Column/Row/Field/Form/Table_Dealer_Portal__c` | A bespoke, metadata-driven form/table builder that renders the dealer self-service portal — not a standard Experience Cloud component. |
| `Partite__c` | Open A/R invoice aging per account. |

Standard objects are heavily extended: `Account` (dealer vs. customer distinctions, Italian fiscal fields, price-list/discount/exclusivity flags), `Opportunity` (`Technology_Type__c`, `Inspection_Automation_Type__c` — visual/contact/laser/robot inspection combinations), `Case` (`Machine_Type__c`, non-conformity tracking, RMA, warranty, repair/scrap cost, two record types: **Service** and **Academy**), `Contract` (service-hours contracts spanning up to 8 linked assets), `Product2` (CN/DE/EN/IT multi-language descriptions), `Quote`/`QuoteLineItem` (Incoterms, dealer commission).

### Automation

- **No formal Approval Processes exist in this org** — the `approvalProcesses/` folder is entirely absent. Even the technical-feasibility sign-off on custom machine requests (`Richiesta_speciale__c`) is a plain picklist status, not a real approval chain.
- ~32 flows, dominated by: web-to-lead capture from the corporate site (built on **Umbraco CMS**), GDPR privacy-notice resend/tracking, Account/Contact/Product normalization onto marketing Campaigns, and multiple product-concept/satisfaction surveys (including one specifically validating a "new optical gantry measuring machine" concept).
- Apex is organized around: the dealer portal CRUD API (`cPortaleRivenditori.cls`), quoting (`cQuote`/`cCreateQuote`, a yearly quote-number-reset scheduled job), GDPR consent enforcement (`cGDPR`, `leadEmailGDPR`/`contactEmailGDPR` triggers), Case/email SLA tracking, the survey platform, standard Experience Cloud self-registration boilerplate, and a Declarative Lookup Rollup Summaries (DLRS) trigger rolling up onto `WorkOrder`.

### UI, access & digital presence

- Two real custom Lightning apps: **`Vici&C`** (core CRM) and the Survey Force app. Everything else (Data Cloud, Agentforce, Commerce, etc.) is unused standard scaffolding.
- Roles model a `Direttore_Commerciale` → `Area_Manager` → `Responsabile_Filiale` hierarchy, plus a 3-tier partner role (Executive/Manager/User) per country/region. Several legacy roles are explicitly flagged **"NONTOCCARE"** ("do not touch") and kept for data integrity.
- Digital Experience / Sites:
  - **Vici Vision** — an older Aura-template Experience Cloud community (partner-facing), retrieved as a `SiteDotCom` bundle (`siteDotComSites/Vici_Vision1.site`) rather than `ExperienceBundle` — see note below.
  - **Marketing Landing Pages** (`Marketing_Landing_Pages1`) — a modern LWR Digital Experience site built with Salesforce CMS, including a `TECMA_2025` content workspace (TECMA is an Italian ceramics-technology trade fair — likely one marketing campaign rather than the core industry vertical) and a `Brand_Center`.
  - **Partner Portal** — a Visualforce-based dealer/reseller self-service site (`portaleRivenditori`).
  - A **GDPR** consent micro-site.
- `it.translation-meta.xml` is essentially empty (no custom label translations) — Italian is simply the org's native base-language labels, which is why that file wasn't itself a useful signal.

### About the "missing" ExperienceBundle

The user's earlier attempt to retrieve `ExperienceBundle` metadata failed, and this was investigated directly against the org:

- `Vici_Vision1` (the Aura-template community) **cannot** be retrieved as `ExperienceBundle` because *"Enable ExperienceBundle Metadata API"* is turned off for Aura sites in **Setup → Digital Experiences → Settings**. Its full page/branding configuration is only exposed via the legacy `SiteDotCom` metadata type, and that bundle (`siteDotComSites/Vici_Vision1.site`, ~570 KB) was already present in the repo.
- `Marketing_Landing_Pages1` isn't an `ExperienceBundle` at all — Salesforce replaced that metadata type with `DigitalExperienceBundle`/`digitalExperiences` + `digitalExperienceConfigs` for newer LWR sites, and that content (routes, branding sets, language settings, app pages) was already fully present in the repo under `digitalExperiences/site/Marketing_Landing_Pages1/`.

**Conclusion: nothing was actually missing.** Everything retrievable for both sites is already in the repo, just under different (and correct) metadata types than `ExperienceBundle`.

## Live data snapshot (queried 2026-07-28)

| Object | Count | Note |
|---|---|---|
| Lead | 45,614 | Large marketing-driven top-of-funnel |
| Account | 19,902 | See breakdown below — mostly prospects, not customers |
| Contact | 26,417 | |
| Opportunity | 14,941 | See stage breakdown below |
| Case | 21,538 | Service/support volume |
| Asset_Vici__c | 3,327 | Installed machines being tracked |
| AssetActivationRegisterSQLite__c | 1,000 | HASP license activation log |
| WorkOrder | 178 | Field-service/repair work orders |
| Contratto_dealer__c | 1 | Only a single record exists — this object looks like a pilot/early-stage initiative, not yet broadly adopted |
| Survey__c | 20 | Survey definitions |
| SurveyTaker__c | 365 | Survey responses collected |

**Account by Type** (top values): Potenziale Cliente (potential customer) 16,107 · Potential Customer 1,430 · Cliente finale (final customer) 1,363 · Potenziale Dealer 385 · Customer 205 · Sub-Dealer 112 · Dealer 88 · Competitor 42 · OEM System Integrator 21 · Out of Business 13 · Segnalatore (referrer) 12.
→ The account base is overwhelmingly prospecting/marketing data (~90%+ potential customers), with a comparatively small base of ~1,760 real customers and ~200 dealer/sub-dealer accounts actually transacting.

**Opportunity by Stage**: Chiuse/Perse (Closed Lost) 9,277 · Chiuse/Conseguite (Closed Won) 4,389 · Qualification 461 · Quote/Negotiation 426 · Application Analysis/Demo 363 · Order waiting 25.
→ Win rate on closed opportunities is roughly 32% (4,389 / (4,389+9,277)). Open pipeline is thin (~1,275 records) relative to the closed-opportunity base, consistent with a mature, long-running CRM rather than a fast-growing one.

**Case by Machine_Type__c**: MTL 10,588 · (blank) 9,142 · METRIOS 1,692 · MTP 116.
→ MTL is the product line generating by far the most service/support volume; a large share of historic cases (9,142) predate this field being populated.

**Note on `Opportunity.Technology_Type__c`**: every one of the 14,941 opportunities has this field blank. It's defined (Visual/Contact/Laser 2D-3D/Robot combinations) but effectively unused/abandoned in practice — a schema feature that never got adopted operationally.

**Curiosity found while sampling `Asset_Vici__c`**: the `Status_garanzia__c` (warranty status) field renders as an inline `<img>` HTML tag (a colored priority-flag icon) rather than plain text — a classic Salesforce "traffic-light" formula-field trick to visually flag warranty status in list views/reports, rather than an app bug.

## Notable / unusual characteristics of this org

1. **Bespoke Dealer Portal** — a full metadata-driven form/table/field builder (`*_Dealer_Portal__c` objects + `cPortaleRivenditori.cls` + `gn*.js` static resources), not a standard Experience Cloud component.
2. **Capital-equipment software licensing** — `AssetActivationRegisterSQLite__c` ties physical machine serials to HASP dongle software-license activations, unlike typical per-seat SaaS licensing.
3. **Zero approval processes** anywhere in the org, despite having a clear candidate use case (special machine request sign-off).
4. **Two third-party packages**: a GSurvey/SurveyForce-derived survey engine and Declarative Lookup Rollup Summaries (DLRS) for `WorkOrder` rollups.
5. **Multi-language commercial operation baked into schema**: Product2 (CN/DE/EN/IT descriptions), Quote (Incoterms `Resa__c`, dealer commission `Provvigione__c`), surveys in IT/EN/DE.
6. Legacy roles explicitly marked **"NONTOCCARE"** — protected from cleanup by whoever manages the org.
7. `Contratto_dealer__c` (the formal dealer-contract object) has exactly **one** record — it exists in the schema/automation but was never operationally rolled out, or is brand new.
8. `Opportunity.Technology_Type__c` and related inspection-technology fields are fully defined but **100% unpopulated** across ~15K records — dead schema that sales never adopted.
