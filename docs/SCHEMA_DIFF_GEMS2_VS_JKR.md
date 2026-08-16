# Schema Diff: Global FM (gems2) vs JKR (gems)

**Generated:** 2026-08-12 21:03:32

## Environments

| Side | Label | Database | Host | MariaDB |
|------|-------|----------|------|---------|
| A | Global FM | `gems2` | `GFMGEMS02` | `10.4.31-MariaDB` |
| B | JKR | `gems` | `CMMS-GEMS-DB` | `10.10.2-MariaDB` |

Queried via `maintenance/db_query_tool.php` (`action=execute`) with `x-api-key`.

## Summary

| Metric | Global FM | JKR |
|--------|-----------|-----|
| Base tables | 145 | 145 |
| Columns | 1534 | 1526 |
| Index entries | 479 | 509 |
| Foreign key column refs | 223 | 240 |
| Tables only in Global FM | 1 | — |
| Tables only in JKR | — | 1 |
| Common tables | 144 | 144 |
| Common tables with column diffs | 75 | 75 |
| Common tables with index diffs | 31 | 31 |
| Common tables with FK diffs | 21 | 21 |

## Notification deploy callout

| Object | Global FM | JKR | Needed for new push code? |
|--------|-----------|-----|---------------------------|
| `noti_send.noti_data` | YES | NO | Yes |
| `noti_log.noti_data` | YES | NO | Yes |
| `noti_log.noti_log_read_at` | YES | NO | Yes |
| `sys_user.user_token` | YES | YES | Existing |

**JKR is missing notification columns:** `noti_send.noti_data`, `noti_log.noti_data`, `noti_log.noti_log_read_at`. Run `maintenance/add_noti_data_columns.sql` on JKR before deploying push code.

## Tables only in Global FM (gems2)

- `vw_ppm_set_asset_details`

## Tables only in JKR

- `wo_task_out_scope`

## Column differences (common tables)

### `ast_asset`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `asset_life_cycle` | Global FM | `smallint(3)` | YES | `NULL` |  |  |
| `asset_life_cycle` | JKR | `smallint(6)` | YES | `NULL` |  |  |
| `asset_no` | Global FM | `varchar(100)` | YES | `NULL` | MUL |  |
| `asset_no` | JKR | `varchar(100)` | YES | `NULL` |  |  |
| `zone_id` | Global FM | `smallint(6)` | YES | `NULL` | MUL |  |
| `zone_id` | JKR | `smallint(6)` | YES | `NULL` |  |  |

### `ast_part_sub`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `part_sub_return_id` | Global FM | `bigint(20)` | YES | `NULL` | MUL |  |
| `part_sub_return_id` | JKR | `bigint(20)` | YES | `NULL` |  |  |
| `part_sub_returned_by` | Global FM | `int(11)` | YES | `NULL` | MUL |  |
| `part_sub_returned_by` | JKR | `int(11)` | YES | `NULL` |  |  |
| `part_sub_returned_date` | Global FM | `datetime` | YES | `NULL` | MUL |  |
| `part_sub_returned_date` | JKR | `datetime` | YES | `NULL` |  |  |

### `att_group`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `att_group_holiday` | Global FM | `enum('Saturday & Sunday','Sunday')` | YES | `NULL` |  |  |
| `att_group_holiday` | JKR | `enum('Saturday & Sunday','Sunday')` | YES | `NULL` |  |  |
| `att_group_name` | Global FM | `varchar(150)` | NO | `None` |  |  |
| `att_group_name` | JKR | `varchar(150)` | NO | `None` |  |  |
| `att_group_remark` | Global FM | `text` | YES | `NULL` |  |  |
| `att_group_remark` | JKR | `text` | YES | `NULL` |  |  |
| `att_group_shift_mode` | Global FM | `enum('Normal','2 Shifts','3 Shifts')` | YES | `NULL` |  |  |
| `att_group_shift_mode` | JKR | `enum('Normal','2 Shifts','3 Shifts')` | YES | `NULL` |  |  |

### `att_participant`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `att_participant_competency` | Global FM | `varchar(50)` | YES | `NULL` |  |  |
| `att_participant_competency` | JKR | `varchar(50)` | YES | `NULL` |  |  |
| `att_participant_gf_id` | Global FM | `varchar(100)` | YES | `''` |  |  |
| `att_participant_gf_id` | JKR | `varchar(100)` | YES | `''` |  |  |
| `att_participant_holiday` | Global FM | `enum('Sunday','Saturday & Sunday')` | YES | `NULL` |  |  |
| `att_participant_holiday` | JKR | `enum('Sunday','Saturday & Sunday')` | YES | `NULL` |  |  |
| `att_participant_shift_mode` | Global FM | `enum('Normal','2 Shifts','3 Shifts')` | YES | `NULL` |  |  |
| `att_participant_shift_mode` | JKR | `enum('Normal','2 Shifts','3 Shifts')` | YES | `NULL` |  |  |
| `att_participant_year_service` | Global FM | `varchar(10)` | YES | `NULL` |  |  |
| `att_participant_year_service` | JKR | `varchar(10)` | YES | `NULL` |  |  |

### `att_transaction`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `att_transaction_result` | Global FM | `enum('Present','Absent','Leave','Training')` | YES | `NULL` |  |  |
| `att_transaction_result` | JKR | `enum('Present','Absent','Leave','Training')` | YES | `NULL` |  |  |
| `att_transaction_status` | Global FM | `enum('Checked In','Checked Out','Ready')` | NO | `'Ready'` |  |  |
| `att_transaction_status` | JKR | `enum('Checked In','Checked Out','Ready')` | NO | `'Ready'` |  |  |

### `att_type`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `att_type_color` | Global FM | `varchar(30)` | YES | `NULL` |  |  |
| `att_type_color` | JKR | `varchar(30)` | YES | `NULL` |  |  |
| `att_type_color_done` | Global FM | `varchar(30)` | YES | `NULL` |  |  |
| `att_type_color_done` | JKR | `varchar(30)` | YES | `NULL` |  |  |
| `att_type_mode` | Global FM | `enum('Normal','2 Shifts','3 Shifts','Leave','Training')` | YES | `NULL` |  |  |
| `att_type_mode` | JKR | `enum('Normal','2 Shifts','3 Shifts','Leave','Training')` | YES | `NULL` |  |  |
| `att_type_name` | Global FM | `varchar(50)` | NO | `None` |  |  |
| `att_type_name` | JKR | `varchar(50)` | NO | `None` |  |  |
| `att_type_short` | Global FM | `varchar(2)` | NO | `None` |  |  |
| `att_type_short` | JKR | `varchar(2)` | NO | `None` |  |  |

### `email_log`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `email_address` | Global FM | `varchar(50)` | NO | `None` |  |  |
| `email_address` | JKR | `varchar(50)` | NO | `None` |  |  |
| `email_attachment` | Global FM | `varchar(150)` | YES | `NULL` |  |  |
| `email_attachment` | JKR | `varchar(150)` | YES | `NULL` |  |  |
| `email_filename` | Global FM | `varchar(100)` | YES | `NULL` |  |  |
| `email_filename` | JKR | `varchar(100)` | YES | `NULL` |  |  |
| `email_html` | Global FM | `text` | NO | `None` |  |  |
| `email_html` | JKR | `text` | NO | `None` |  |  |
| `email_title` | Global FM | `varchar(150)` | NO | `None` |  |  |
| `email_title` | JKR | `varchar(150)` | NO | `None` |  |  |

### `email_parameter`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `email_param_code` | Global FM | `varchar(30)` | NO | `None` |  |  |
| `email_param_code` | JKR | `varchar(30)` | NO | `None` |  |  |
| `email_param_desc` | Global FM | `varchar(150)` | YES | `NULL` |  |  |
| `email_param_desc` | JKR | `varchar(150)` | YES | `NULL` |  |  |

### `email_send`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `email_address` | Global FM | `varchar(50)` | NO | `None` |  |  |
| `email_address` | JKR | `varchar(50)` | NO | `None` |  |  |
| `email_attachment` | Global FM | `varchar(150)` | YES | `NULL` |  |  |
| `email_attachment` | JKR | `varchar(150)` | YES | `NULL` |  |  |
| `email_filename` | Global FM | `varchar(100)` | YES | `NULL` |  |  |
| `email_filename` | JKR | `varchar(100)` | YES | `NULL` |  |  |
| `email_html` | Global FM | `text` | NO | `None` |  |  |
| `email_html` | JKR | `text` | NO | `None` |  |  |
| `email_title` | Global FM | `varchar(150)` | NO | `None` |  |  |
| `email_title` | JKR | `varchar(150)` | NO | `None` |  |  |

### `email_template`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `email_template_desc` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `email_template_desc` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `email_template_html` | Global FM | `text` | NO | `None` |  |  |
| `email_template_html` | JKR | `text` | NO | `None` |  |  |
| `email_template_name` | Global FM | `varchar(150)` | NO | `None` |  |  |
| `email_template_name` | JKR | `varchar(150)` | NO | `None` |  |  |
| `email_template_title` | Global FM | `varchar(150)` | NO | `None` |  |  |
| `email_template_title` | JKR | `varchar(150)` | NO | `None` |  |  |

### `fca_defect_category`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `fca_defect_category_name` | Global FM | `varchar(100)` | NO | `None` |  |  |
| `fca_defect_category_name` | JKR | `varchar(100)` | NO | `None` |  |  |

### `fca_report`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `fca_report_name` | Global FM | `varchar(200)` | YES | `NULL` |  |  |
| `fca_report_name` | JKR | `varchar(200)` | YES | `NULL` |  |  |
| `fca_report_sort_by` | Global FM | `varchar(30)` | YES | `NULL` |  |  |
| `fca_report_sort_by` | JKR | `varchar(30)` | YES | `NULL` |  |  |

### `fca_task`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `fca_task_area` | Global FM | `varchar(100)` | YES | `NULL` |  |  |
| `fca_task_area` | JKR | `varchar(100)` | YES | `NULL` |  |  |
| `fca_task_asset_evaluated` | Global FM | `varchar(100)` | YES | `NULL` |  |  |
| `fca_task_asset_evaluated` | JKR | `varchar(100)` | YES | `NULL` |  |  |
| `fca_task_asset_no` | Global FM | `varchar(50)` | YES | `NULL` |  |  |
| `fca_task_asset_no` | JKR | `varchar(50)` | YES | `NULL` |  |  |
| `fca_task_defect_item` | Global FM | `varchar(100)` | YES | `NULL` |  |  |
| `fca_task_defect_item` | JKR | `varchar(100)` | YES | `NULL` |  |  |
| `fca_task_no` | Global FM | `varchar(30)` | YES | `NULL` |  |  |
| `fca_task_no` | JKR | `varchar(30)` | YES | `NULL` |  |  |
| `fca_task_observation` | Global FM | `text` | YES | `NULL` |  |  |
| `fca_task_observation` | JKR | `text` | YES | `NULL` |  |  |
| `fca_task_recommendation` | Global FM | `text` | YES | `NULL` |  |  |
| `fca_task_recommendation` | JKR | `text` | YES | `NULL` |  |  |
| `fca_task_validation` | Global FM | `text` | YES | `NULL` |  |  |
| `fca_task_validation` | JKR | `text` | YES | `NULL` |  |  |

### `fca_task_section`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `fca_task_section_code` | Global FM | `varchar(1)` | NO | `None` |  |  |
| `fca_task_section_code` | JKR | `varchar(1)` | NO | `None` |  |  |
| `fca_task_section_name` | Global FM | `varchar(100)` | NO | `None` |  |  |
| `fca_task_section_name` | JKR | `varchar(100)` | NO | `None` |  |  |

### `fca_zone`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `fca_zone_name` | Global FM | `varchar(200)` | NO | `None` |  |  |
| `fca_zone_name` | JKR | `varchar(200)` | NO | `None` |  |  |

### `gmi_config`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `status` | Global FM | `tinyint(1)` | NO | `1` | MUL |  |
| `status` | JKR | `tinyint(1)` | NO | `1` |  |  |

### `gmi_monthly`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `gmi_ppm_tier_name` | Global FM | `varchar(20)` | YES | `NULL` |  |  |
| `gmi_ppm_tier_name` | JKR | `varchar(20)` | YES | `NULL` |  |  |
| `gmi_wo_tier_name` | Global FM | `varchar(20)` | YES | `NULL` |  |  |
| `gmi_wo_tier_name` | JKR | `varchar(20)` | YES | `NULL` |  |  |

### `gmi_weekly`

**Columns only in Global FM:**
- `gmi_id` (bigint(20), null=NO)
- `gmi_ppm_completed` (smallint(6), null=YES)
- `gmi_ppm_total` (smallint(6), null=YES)
- `gmi_wo_completed` (smallint(6), null=YES)
- `gmi_wo_total` (smallint(6), null=YES)
- `week_end` (date, null=YES)
- `week_start` (date, null=YES)

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `gmw_id` | Global FM | `bigint(20)` | YES | `NULL` |  |  |
| `gmw_id` | JKR | `bigint(20)` | NO | `None` | PRI | auto_increment |
| `gmw_ppm_tier_name` | Global FM | `varchar(20)` | YES | `NULL` |  |  |
| `gmw_ppm_tier_name` | JKR | `varchar(20)` | YES | `NULL` |  |  |
| `gmw_wo_tier_name` | Global FM | `varchar(20)` | YES | `NULL` |  |  |
| `gmw_wo_tier_name` | JKR | `varchar(20)` | YES | `NULL` |  |  |

### `inventory_logs`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `change_date` | Global FM | `datetime` | NO | `current_timestamp()` |  |  |
| `change_date` | JKR | `datetime` | NO | `current_timestamp()` | MUL |  |
| `change_type` | Global FM | `enum('purchase','checkout','return','adjustment','transfer')` | NO | `None` |  |  |
| `change_type` | JKR | `enum('purchase','checkout','return','adjustment','transfer')` | NO | `None` | MUL |  |
| `part_id` | Global FM | `bigint(20)` | NO | `None` |  |  |
| `part_id` | JKR | `bigint(20)` | NO | `None` | MUL |  |
| `reference_type` | Global FM | `varchar(50)` | YES | `NULL` |  |  |
| `reference_type` | JKR | `varchar(50)` | YES | `NULL` | MUL |  |
| `user_id` | Global FM | `int(11)` | NO | `None` |  |  |
| `user_id` | JKR | `int(11)` | NO | `None` | MUL |  |

### `kpi`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `kpi_month` | Global FM | `tinyint(2)` | NO | `None` |  |  |
| `kpi_month` | JKR | `tinyint(4)` | NO | `None` |  |  |
| `kpi_year` | Global FM | `smallint(4)` | NO | `None` |  |  |
| `kpi_year` | JKR | `smallint(6)` | NO | `None` |  |  |

### `lic_license`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `site_id` | Global FM | `smallint(6)` | NO | `None` |  |  |
| `site_id` | JKR | `smallint(6)` | NO | `None` | MUL |  |
| `upload_id` | Global FM | `bigint(20)` | YES | `NULL` |  |  |
| `upload_id` | JKR | `bigint(20)` | YES | `NULL` | MUL |  |

### `noti_log`

**Columns only in Global FM:**
- `noti_data` (text, null=YES)
- `noti_log_read_at` (timestamp, null=YES)

### `noti_send`

**Columns only in Global FM:**
- `noti_data` (text, null=YES)

### `noti_web`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `noti_web_color` | Global FM | `varchar(30)` | NO | `None` |  |  |
| `noti_web_color` | JKR | `varchar(30)` | NO | `None` |  |  |
| `noti_web_icon` | Global FM | `varchar(30)` | NO | `None` |  |  |
| `noti_web_icon` | JKR | `varchar(30)` | NO | `None` |  |  |
| `noti_web_link` | Global FM | `varchar(100)` | YES | `NULL` |  |  |
| `noti_web_link` | JKR | `varchar(100)` | YES | `NULL` |  |  |
| `noti_web_text` | Global FM | `varchar(255)` | NO | `None` |  |  |
| `noti_web_text` | JKR | `varchar(255)` | NO | `None` |  |  |
| `noti_web_title` | Global FM | `varchar(30)` | NO | `None` |  |  |
| `noti_web_title` | JKR | `varchar(30)` | NO | `None` |  |  |

### `ppm`

**Columns only in JKR:**
- `ppm_is_routine` (tinyint(1), null=NO)

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `ppm_set_id` | Global FM | `smallint(6)` | YES | `NULL` | MUL |  |
| `ppm_set_id` | JKR | `smallint(6)` | YES | `NULL` |  |  |

### `ppm_checklist_quan`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `checklist_quan_desc` | Global FM | `text` | YES | `NULL` |  |  |
| `checklist_quan_desc` | JKR | `text` | YES | `NULL` |  |  |

### `ppm_offline_sync_log`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `created_at` | Global FM | `datetime` | NO | `current_timestamp()` |  |  |
| `created_at` | JKR | `datetime` | NO | `current_timestamp()` | MUL |  |
| `ppm_task_id` | Global FM | `varchar(50)` | NO | `None` |  |  |
| `ppm_task_id` | JKR | `varchar(50)` | NO | `None` | MUL |  |
| `user_id` | Global FM | `int(11)` | NO | `None` |  |  |
| `user_id` | JKR | `int(11)` | NO | `None` | MUL |  |

### `ppm_set`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `ppm_set_desc` | Global FM | `varchar(1000)` | YES | `NULL` |  |  |
| `ppm_set_desc` | JKR | `varchar(1000)` | YES | `NULL` |  |  |
| `ppm_set_name` | Global FM | `varchar(200)` | YES | `NULL` |  |  |
| `ppm_set_name` | JKR | `varchar(200)` | YES | `NULL` |  |  |

### `ppm_task`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `ppm_task_no` | Global FM | `varchar(30)` | YES | `NULL` | MUL |  |
| `ppm_task_no` | JKR | `varchar(30)` | YES | `NULL` |  |  |

### `ptw_approval_log`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `ptw_permit_id` | Global FM | `int(11)` | NO | `None` |  |  |
| `ptw_permit_id` | JKR | `int(11)` | NO | `None` | MUL |  |

### `ptw_document`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `document_category` | Global FM | `enum('SUPPORTING_DOC','CERTIFICATE','PERMIT','OTHER')` | YES | `'SUPPORTING_DOC'` |  |  |
| `document_category` | JKR | `enum('SUPPORTING_DOC','CERTIFICATE','PERMIT','OTHER')` | YES | `'SUPPORTING_DOC'` | MUL |  |
| `ptw_permit_id` | Global FM | `int(11)` | NO | `None` |  |  |
| `ptw_permit_id` | JKR | `int(11)` | NO | `None` | MUL |  |

### `ptw_number_sequence`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `updated_at` | Global FM | `datetime` | NO | `current_timestamp()` |  |  |
| `updated_at` | JKR | `datetime` | NO | `current_timestamp()` | MUL |  |

### `ptw_permit`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `ptw_work_type` | Global FM | `enum('HOT_WORK','COLD_WORK','ELECTRICAL','CONFINED_SPACE','HEIGHT_WORK','EXCAVATION','CHEMICAL','LIFTING','MECHANICAL','OTHER')` | NO | `'COLD_WORK'` |  |  |
| `ptw_work_type` | JKR | `enum('Cold Work','Hot Work','Confined Space')` | NO | `None` |  |  |

### `ptw_status_history`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `action_date` | Global FM | `timestamp` | NO | `current_timestamp()` |  |  |
| `action_date` | JKR | `timestamp` | NO | `current_timestamp()` | MUL |  |
| `action_type` | Global FM | `enum('DRAFT','SUBMITTED','PENDING_SUPERVISOR','PENDING_SHE','PENDING_FM','APPROVED','ACTIVE','PENDING_CLOSURE','COMPLETED','PENDING_CANCELLATION','PENDING_SUSPENSION','PENDING_EXTENSION','CANCELLED','SUSPENDED','REJECTED','EXTENDED')` | NO | `None` |  |  |
| `action_type` | JKR | `enum('DRAFT','SUBMITTED','PENDING_SUPERVISOR','PENDING_SHE','PENDING_FM','APPROVED','ACTIVE','PENDING_CLOSURE','COMPLETED','PENDING_CANCELLATION','PENDING_SUSPENSION','PENDING_EXTENSION','CANCELLED','SUSPENDED','REJECTED','EXTENDED')` | NO | `None` | MUL |  |
| `ptw_permit_id` | Global FM | `int(11)` | NO | `None` |  |  |
| `ptw_permit_id` | JKR | `int(11)` | NO | `None` | MUL |  |

### `ptw_worker`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `ptw_permit_id` | Global FM | `int(11)` | NO | `None` |  |  |
| `ptw_permit_id` | JKR | `int(11)` | NO | `None` | MUL |  |

### `ref_city`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `city_desc` | Global FM | `varchar(255)` | NO | `None` | MUL |  |
| `city_desc` | JKR | `varchar(255)` | NO | `None` | MUL |  |

### `ref_country`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `country_desc` | Global FM | `varchar(50)` | NO | `None` |  |  |
| `country_desc` | JKR | `varchar(50)` | NO | `None` |  |  |

### `ref_document`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `document_desc` | Global FM | `varchar(150)` | NO | `None` |  |  |
| `document_desc` | JKR | `varchar(150)` | NO | `None` |  |  |
| `document_type` | Global FM | `varchar(100)` | YES | `NULL` |  |  |
| `document_type` | JKR | `varchar(100)` | YES | `NULL` |  |  |

### `ref_space_category`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `space_category_name` | Global FM | `varchar(100)` | NO | `None` |  |  |
| `space_category_name` | JKR | `varchar(100)` | NO | `None` | UNI |  |

### `ref_space_location`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `space_location_name` | Global FM | `varchar(100)` | NO | `None` |  |  |
| `space_location_name` | JKR | `varchar(100)` | NO | `None` | UNI |  |

### `ref_space_type`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `space_category_id` | Global FM | `smallint(5) unsigned` | NO | `None` |  |  |
| `space_category_id` | JKR | `smallint(5) unsigned` | NO | `None` | MUL |  |
| `space_type_name` | Global FM | `varchar(100)` | NO | `None` |  |  |
| `space_type_name` | JKR | `varchar(100)` | NO | `None` | UNI |  |

### `ref_state`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `state_desc` | Global FM | `varchar(50)` | NO | `''` | MUL |  |
| `state_desc` | JKR | `varchar(50)` | NO | `''` | MUL |  |

### `spc_reservation`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `reservation_status` | Global FM | `varchar(20)` | NO | `'RESERVED'` |  |  |
| `reservation_status` | JKR | `varchar(20)` | NO | `'RESERVED'` | MUL |  |
| `site_id` | Global FM | `smallint(5) unsigned` | NO | `None` |  |  |
| `site_id` | JKR | `smallint(5) unsigned` | NO | `None` | MUL |  |
| `space_id` | Global FM | `int(10) unsigned` | NO | `None` |  |  |
| `space_id` | JKR | `int(10) unsigned` | NO | `None` | MUL |  |

### `spc_space`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `site_id` | Global FM | `smallint(5) unsigned` | NO | `None` |  |  |
| `site_id` | JKR | `smallint(5) unsigned` | NO | `None` | MUL |  |
| `space_category_id` | Global FM | `smallint(5) unsigned` | YES | `NULL` |  |  |
| `space_category_id` | JKR | `smallint(5) unsigned` | YES | `NULL` | MUL |  |
| `space_location_id` | Global FM | `smallint(5) unsigned` | YES | `NULL` |  |  |
| `space_location_id` | JKR | `smallint(5) unsigned` | YES | `NULL` | MUL |  |
| `space_status` | Global FM | `varchar(20)` | NO | `'AVAILABLE'` |  |  |
| `space_status` | JKR | `varchar(20)` | NO | `'AVAILABLE'` | MUL |  |
| `space_type_id` | Global FM | `smallint(5) unsigned` | YES | `NULL` |  |  |
| `space_type_id` | JKR | `smallint(5) unsigned` | YES | `NULL` | MUL |  |

### `spc_space_asset`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `asset_id` | Global FM | `bigint(20)` | NO | `None` |  |  |
| `asset_id` | JKR | `bigint(20)` | NO | `None` | MUL |  |
| `space_id` | Global FM | `int(10) unsigned` | NO | `None` |  |  |
| `space_id` | JKR | `int(10) unsigned` | NO | `None` | MUL |  |

### `spc_space_media`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `space_id` | Global FM | `int(10) unsigned` | NO | `None` |  |  |
| `space_id` | JKR | `int(10) unsigned` | NO | `None` | MUL |  |
| `upload_id` | Global FM | `bigint(20)` | NO | `None` |  |  |
| `upload_id` | JKR | `bigint(20)` | NO | `None` | MUL |  |

### `sys_address`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `address_city` | Global FM | `varchar(100)` | YES | `NULL` |  |  |
| `address_city` | JKR | `varchar(100)` | YES | `NULL` |  |  |
| `address_desc` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `address_desc` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `address_postcode` | Global FM | `varchar(5)` | YES | `NULL` |  |  |
| `address_postcode` | JKR | `varchar(5)` | YES | `NULL` |  |  |

### `sys_audit`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `audit_ip` | Global FM | `varchar(25)` | YES | `NULL` |  |  |
| `audit_ip` | JKR | `varchar(25)` | YES | `NULL` |  |  |
| `audit_place` | Global FM | `varchar(100)` | YES | `NULL` |  |  |
| `audit_place` | JKR | `varchar(100)` | YES | `NULL` |  |  |
| `audit_remark` | Global FM | `text` | YES | `NULL` |  |  |
| `audit_remark` | JKR | `text` | YES | `NULL` |  |  |

### `sys_audit_action`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `audit_action_desc` | Global FM | `varchar(100)` | NO | `None` |  |  |
| `audit_action_desc` | JKR | `varchar(100)` | NO | `None` |  |  |
| `audit_action_status` | Global FM | `tinyint(255)` | NO | `1` | MUL |  |
| `audit_action_status` | JKR | `tinyint(4)` | NO | `1` | MUL |  |

### `sys_audit_module`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `audit_module_desc` | Global FM | `varchar(100)` | NO | `None` |  |  |
| `audit_module_desc` | JKR | `varchar(100)` | NO | `None` |  |  |

### `sys_group`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `group_name` | Global FM | `varchar(150)` | YES | `NULL` |  |  |
| `group_name` | JKR | `varchar(150)` | YES | `NULL` |  |  |
| `group_reg_no` | Global FM | `varchar(30)` | YES | `NULL` |  |  |
| `group_reg_no` | JKR | `varchar(30)` | YES | `NULL` |  |  |

### `sys_location`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `location_desc` | Global FM | `varchar(255)` | NO | `None` |  |  |
| `location_desc` | JKR | `varchar(255)` | NO | `None` |  |  |

### `sys_nav_second`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `nav_second_desc` | Global FM | `varchar(30)` | NO | `None` |  |  |
| `nav_second_desc` | JKR | `varchar(30)` | NO | `None` |  |  |
| `nav_second_page` | Global FM | `varchar(30)` | YES | `NULL` |  |  |
| `nav_second_page` | JKR | `varchar(30)` | YES | `NULL` |  |  |

### `sys_pdf`

**Columns only in JKR:**
- `pdf_time_update` (timestamp, null=NO)

### `sys_site`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `site_code` | Global FM | `varchar(20)` | NO | `None` |  |  |
| `site_code` | JKR | `varchar(20)` | NO | `None` | UNI |  |

### `sys_upload`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `upload_blob_type` | Global FM | `varchar(100)` | NO | `''` |  |  |
| `upload_blob_type` | JKR | `varchar(100)` | NO | `''` |  |  |
| `upload_extension` | Global FM | `varchar(10)` | YES | `NULL` |  |  |
| `upload_extension` | JKR | `varchar(10)` | YES | `NULL` |  |  |
| `upload_filename` | Global FM | `varchar(50)` | YES | `NULL` |  |  |
| `upload_filename` | JKR | `varchar(50)` | YES | `NULL` |  |  |
| `upload_folder` | Global FM | `varchar(100)` | YES | `NULL` |  |  |
| `upload_folder` | JKR | `varchar(100)` | YES | `NULL` |  |  |
| `upload_name` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `upload_name` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `upload_uplname` | Global FM | `varchar(255)` | NO | `''` |  |  |
| `upload_uplname` | JKR | `varchar(255)` | NO | `''` |  |  |

### `sys_user`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `user_type` | Global FM | `tinyint(3)` | NO | `1` | MUL |  |
| `user_type` | JKR | `tinyint(4)` | NO | `1` | MUL |  |

### `sys_user_profile`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `user_contact_no` | Global FM | `varchar(15)` | YES | `NULL` |  |  |
| `user_contact_no` | JKR | `varchar(15)` | YES | `NULL` |  |  |
| `user_email` | Global FM | `varchar(100)` | YES | `NULL` |  |  |
| `user_email` | JKR | `varchar(100)` | YES | `NULL` |  |  |

### `sys_version`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `version_name` | Global FM | `varchar(20)` | NO | `None` |  |  |
| `version_name` | JKR | `varchar(20)` | NO | `None` |  |  |

### `vm_host`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `contact_no` | Global FM | `varchar(50)` | YES | `NULL` |  |  |
| `contact_no` | JKR | `varchar(50)` | YES | `NULL` |  |  |
| `department` | Global FM | `varchar(100)` | YES | `NULL` |  |  |
| `department` | JKR | `varchar(100)` | YES | `NULL` |  |  |
| `email` | Global FM | `varchar(150)` | YES | `NULL` |  |  |
| `email` | JKR | `varchar(150)` | YES | `NULL` |  |  |
| `name` | Global FM | `varchar(100)` | NO | `None` |  |  |
| `name` | JKR | `varchar(100)` | NO | `None` |  |  |
| `site_id` | Global FM | `int(11)` | NO | `None` |  |  |
| `site_id` | JKR | `int(11)` | NO | `None` | MUL |  |

### `vm_visit`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `status` | Global FM | `enum('CHECKED_IN','CHECKED_OUT','CANCELLED')` | NO | `'CHECKED_IN'` |  |  |
| `status` | JKR | `enum('CHECKED_IN','CHECKED_OUT','CANCELLED')` | NO | `'CHECKED_IN'` | MUL |  |

### `wfl_checkpoint`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `checkpoint_color` | Global FM | `varchar(30)` | YES | `NULL` |  |  |
| `checkpoint_color` | JKR | `varchar(30)` | YES | `NULL` |  |  |
| `checkpoint_desc` | Global FM | `varchar(150)` | NO | `None` |  |  |
| `checkpoint_desc` | JKR | `varchar(150)` | NO | `None` |  |  |
| `checkpoint_icon` | Global FM | `varchar(30)` | YES | `NULL` |  |  |
| `checkpoint_icon` | JKR | `varchar(30)` | YES | `NULL` |  |  |

### `wfl_flow`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `flow_desc` | Global FM | `varchar(150)` | NO | `None` |  |  |
| `flow_desc` | JKR | `varchar(150)` | NO | `None` |  |  |

### `wfl_task`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `task_remark` | Global FM | `text` | YES | `NULL` |  |  |
| `task_remark` | JKR | `text` | YES | `NULL` |  |  |

### `wfl_transaction`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `asset_no` | Global FM | `varchar(30)` | YES | `NULL` |  |  |
| `asset_no` | JKR | `text` | YES | `NULL` |  |  |
| `transaction_no` | Global FM | `varchar(30)` | NO | `None` |  |  |
| `transaction_no` | JKR | `varchar(30)` | NO | `None` |  |  |

### `wo_import_batch`

**Columns only in Global FM:**
- `batch_name` (varchar(100), null=NO)
- `batch_time` (timestamp, null=NO)

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `batch_id` | Global FM | `bigint(20)` | NO | `None` | PRI | auto_increment |
| `batch_id` | JKR | `int(11)` | NO | `None` | PRI | auto_increment |

### `wo_import_log`

**Columns only in Global FM:**
- `log_time` (timestamp, null=NO)
- `record_data` (text, null=NO)

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `batch_id` | Global FM | `bigint(20)` | NO | `None` | MUL |  |
| `batch_id` | JKR | `int(11)` | NO | `None` | MUL |  |
| `log_id` | Global FM | `bigint(20)` | NO | `None` | PRI | auto_increment |
| `log_id` | JKR | `int(11)` | NO | `None` | PRI | auto_increment |

### `wo_migration`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `pdf_id` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `pdf_id` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_complaint` | Global FM | `text` | YES | `NULL` |  |  |
| `wo_task_complaint` | JKR | `text` | YES | `NULL` |  |  |
| `wo_task_latitude` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_latitude` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_location` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_location` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_longitude` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_longitude` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_no` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_no` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_repair_desc` | Global FM | `text` | YES | `NULL` |  |  |
| `wo_task_repair_desc` | JKR | `text` | YES | `NULL` |  |  |

### `wo_task`

**Columns only in JKR:**
- `location_code_id` (smallint(6), null=YES)
- `wo_task_done_out_scope` (tinyint(1), null=NO)

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `wo_task_external_ref` | Global FM | `varchar(100)` | YES | `NULL` | MUL |  |
| `wo_task_external_ref` | JKR | `varchar(100)` | YES | `NULL` |  |  |
| `wo_task_is_imported` | Global FM | `tinyint(1)` | NO | `0` | MUL |  |
| `wo_task_is_imported` | JKR | `tinyint(1)` | NO | `0` |  |  |
| `wo_task_location` | Global FM | `varchar(150)` | YES | `NULL` |  |  |
| `wo_task_location` | JKR | `varchar(225)` | YES | `NULL` |  |  |
| `wo_task_severity` | Global FM | `tinyint(1)` | YES | `NULL` | MUL |  |
| `wo_task_severity` | JKR | `tinyint(1)` | YES | `NULL` |  |  |
| `zone_id` | Global FM | `smallint(6)` | YES | `NULL` | MUL |  |
| `zone_id` | JKR | `smallint(6)` | YES | `NULL` |  |  |

### `wo_task_parts`

**Columns only in JKR:**
- `wo_task_parts_return` (int(11), null=YES)

### `wo_task_public`

**Columns only in Global FM:**
- `public_id` (bigint(20), null=NO)
- `public_time` (timestamp, null=NO)

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `transaction_id` | Global FM | `bigint(20)` | YES | `NULL` | MUL |  |
| `transaction_id` | JKR | `bigint(20)` | NO | `None` | MUL |  |
| `wo_task_public` | Global FM | `bigint(20)` | YES | `NULL` |  |  |
| `wo_task_public` | JKR | `bigint(20)` | NO | `None` | PRI | auto_increment |
| `wo_task_public_agency` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_public_agency` | JKR | `varchar(200)` | YES | `NULL` |  |  |
| `wo_task_public_complaint` | Global FM | `text` | YES | `NULL` |  |  |
| `wo_task_public_complaint` | JKR | `text` | YES | `NULL` |  |  |
| `wo_task_public_email` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_public_email` | JKR | `varchar(100)` | YES | `NULL` |  |  |
| `wo_task_public_ic_no` | Global FM | `varchar(50)` | YES | `NULL` |  |  |
| `wo_task_public_ic_no` | JKR | `varchar(12)` | YES | `NULL` |  |  |
| `wo_task_public_name` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_public_name` | JKR | `varchar(200)` | YES | `NULL` |  |  |
| `wo_task_public_phone_no` | Global FM | `varchar(50)` | YES | `NULL` |  |  |
| `wo_task_public_phone_no` | JKR | `varchar(15)` | YES | `NULL` |  |  |

### `wo_task_request`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `store_id` | Global FM | `smallint(6)` | YES | `NULL` | MUL |  |
| `store_id` | JKR | `smallint(6)` | YES | `NULL` |  |  |
| `wo_task_request_mrf_pdf` | Global FM | `bigint(20)` | YES | `NULL` | MUL |  |
| `wo_task_request_mrf_pdf` | JKR | `bigint(20)` | YES | `NULL` |  |  |
| `wo_task_request_severity` | Global FM | `tinyint(1)` | YES | `NULL` | MUL |  |
| `wo_task_request_severity` | JKR | `tinyint(1)` | YES | `NULL` |  |  |

### `wo_task_request_2`

**Columns only in Global FM:**
- `additional_info` (text, null=YES)
- `request2_id` (bigint(20), null=NO)
- `request2_time_created` (timestamp, null=NO)

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `wo_task_request_id` | Global FM | `bigint(20)` | YES | `NULL` | MUL |  |
| `wo_task_request_id` | JKR | `bigint(20)` | NO | `None` | PRI | auto_increment |

### `z_migration`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `ppm_group_id` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `ppm_group_id` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_assigned_by` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_assigned_by` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_created_by` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_created_by` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_desc` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_desc` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_fixed_by` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_fixed_by` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_location` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_location` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_no` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_no` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_repair_desc` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_repair_desc` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_severity` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_severity` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_status` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_status` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_type` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_type` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_verified_by` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `wo_task_verified_by` | JKR | `varchar(255)` | YES | `NULL` |  |  |

### `z_raw`

**Changed columns:**

| Column | Side | TYPE | NULL | DEFAULT | KEY | EXTRA |
|--------|------|------|------|---------|-----|-------|
| `Action Time(Minute)` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `Action Time(Minute)` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `Assigned By` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `Assigned By` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `Assigned Time` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `Assigned Time` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `Complainant` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `Complainant` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `Complaint Time` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `Complaint Time` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `Customer Type` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `Customer Type` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `Executed Time` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `Executed Time` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `Fixed By` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `Fixed By` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `Location Description` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `Location Description` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `Progress` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `Progress` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `Repair Description` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `Repair Description` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `Respond Duration` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `Respond Duration` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `Severity` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `Severity` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `Trade` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `Trade` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `Verified By` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `Verified By` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `Verified Time` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `Verified Time` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `Work Order Description` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `Work Order Description` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `Work Order No.` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `Work Order No.` | JKR | `varchar(255)` | YES | `NULL` |  |  |
| `Work Order Type` | Global FM | `varchar(255)` | YES | `NULL` |  |  |
| `Work Order Type` | JKR | `varchar(255)` | YES | `NULL` |  |  |

## Index differences (common tables)

### `ast_asset`

**Indexes only in Global FM:** `idx_asset_id`, `idx_asset_no`, `zone_id`

### `ast_part_sub`

**Indexes only in Global FM:** `fk_part_sub_returned_by`, `idx_return_id`, `idx_returned_date`

### `gmi_config`

**Indexes only in Global FM:** `idx_gmi_config_key`, `idx_gmi_config_status`, `ux_gmi_config_key`

### `gmi_weekly`

**Changed indexes:** `PRIMARY`
- `PRIMARY` Global FM: non_unique=0 type=BTREE cols=('gmi_id',)
- `PRIMARY` JKR: non_unique=0 type=BTREE cols=('gmw_id',)

### `inventory_logs`

**Indexes only in JKR:** `idx_change_date`, `idx_change_type`, `idx_part_id`, `idx_reference`, `user_id`

### `lic_license`

**Indexes only in JKR:** `site_id`, `upload_id`

### `ppm`

**Indexes only in Global FM:** `ppm_ibfk_6`

### `ppm_frequency`

**Indexes only in JKR:** `frequency_id`, `frequency_id_2`

### `ppm_offline_sync_log`

**Indexes only in JKR:** `idx_created`, `idx_ppm_task`, `idx_user`, `unique_sync`

### `ppm_task`

**Indexes only in Global FM:** `idx_ppm_task_assigned`, `idx_ppm_task_no`, `idx_ppm_task_status`
**Indexes only in JKR:** `ppm_task_id`, `ppm_task_id_2`

### `ptw_approval_log`

**Indexes only in JKR:** `idx_ptw_approval_permit_id`

### `ptw_document`

**Indexes only in JKR:** `idx_ptw_document_category`, `idx_ptw_document_permit_id`

### `ptw_number_sequence`

**Indexes only in JKR:** `idx_seq_updated`

### `ptw_status_history`

**Indexes only in JKR:** `idx_ptw_status_action_date`, `idx_ptw_status_action_type`, `idx_ptw_status_permit_id`

### `ptw_worker`

**Indexes only in JKR:** `idx_ptw_worker_permit_id`

### `ref_space_category`

**Indexes only in JKR:** `uq_ref_space_category_name`

### `ref_space_location`

**Indexes only in JKR:** `uq_ref_space_location_name`

### `ref_space_type`

**Indexes only in JKR:** `idx_ref_space_type_category`, `uq_ref_space_type_name`

### `spc_reservation`

**Indexes only in JKR:** `idx_spc_reservation_site`, `idx_spc_reservation_space`, `idx_spc_reservation_status`

### `spc_space`

**Indexes only in JKR:** `fk_spc_space_category`, `fk_spc_space_location`, `fk_spc_space_type`, `idx_spc_space_site`, `idx_spc_space_status`, `uq_spc_space_site_name`

### `spc_space_asset`

**Indexes only in JKR:** `idx_spc_space_asset_asset`, `uq_spc_space_asset`

### `spc_space_media`

**Indexes only in JKR:** `fk_spc_space_media_upload`, `idx_spc_space_media_cover`, `idx_spc_space_media_space`

### `sys_nav_role`

**Indexes only in Global FM:** `ux_sys_nav_role_id`

### `sys_site`

**Indexes only in JKR:** `site_code`

### `sys_user`

**Indexes only in Global FM:** `idx_user_name`

### `vm_host`

**Indexes only in JKR:** `uq_vm_host_site_name`

### `vm_visit`

**Indexes only in JKR:** `idx_vm_visit_status`

### `wo_task`

**Indexes only in Global FM:** `idx_external_ref`, `idx_is_imported`, `wo_task_severity`, `zone_id`

### `wo_task_public`

**Changed indexes:** `PRIMARY`
- `PRIMARY` Global FM: non_unique=0 type=BTREE cols=('public_id',)
- `PRIMARY` JKR: non_unique=0 type=BTREE cols=('wo_task_public',)

### `wo_task_request`

**Indexes only in Global FM:** `store_id`, `wo_task_request_mrf_pdf`, `wo_task_request_severity`

### `wo_task_request_2`

**Indexes only in Global FM:** `wo_task_request_2_ibfk_1`
**Changed indexes:** `PRIMARY`
- `PRIMARY` Global FM: non_unique=0 type=BTREE cols=('request2_id',)
- `PRIMARY` JKR: non_unique=0 type=BTREE cols=('wo_task_request_id',)

## Foreign key differences (common tables)

### `ast_asset`

**FKs only in Global FM:** `ast_asset_ibfk_12`

### `ast_part_sub`

**FKs only in Global FM:** `fk_part_sub_return`, `fk_part_sub_returned_by`

### `gmi_weekly`

**FKs only in Global FM:** `gmi_weekly_ibfk_1`

### `inventory_logs`

**FKs only in JKR:** `inventory_logs_ibfk_1`, `inventory_logs_ibfk_2`

### `lic_license`

**FKs only in JKR:** `lic_license_ibfk_1`, `lic_license_ibfk_2`

### `material_returns`

**FKs only in JKR:** `material_returns_ibfk_1`, `material_returns_ibfk_2`, `material_returns_ibfk_3`, `material_returns_ibfk_4`

### `ppm`

**FKs only in Global FM:** `ppm_ibfk_6`

### `ptw_approval_log`

**FKs only in JKR:** `fk_ptw_approval_permit`

### `ptw_document`

**FKs only in JKR:** `fk_ptw_document_permit`

### `ptw_status_history`

**FKs only in JKR:** `fk_ptw_status_permit`

### `ptw_worker`

**FKs only in JKR:** `fk_ptw_worker_permit`

### `spc_reservation`

**FKs only in JKR:** `fk_spc_reservation_space`

### `spc_space`

**FKs only in JKR:** `fk_spc_space_category`, `fk_spc_space_location`, `fk_spc_space_type`

### `spc_space_asset`

**FKs only in JKR:** `fk_spc_space_asset_asset`, `fk_spc_space_asset_space`

### `spc_space_media`

**FKs only in JKR:** `fk_spc_space_media_space`, `fk_spc_space_media_upload`

### `sys_user_signature`

**FKs only in JKR:** `fk_user_sig_user`

### `vm_visit`

**FKs only in JKR:** `fk_vm_visit_site`

### `wo_task`

**FKs only in Global FM:** `wo_task_ibfk_13`

### `wo_task_public`

**FKs only in JKR:** `wo_task_public_ibfk_2`, `wo_task_public_ibfk_3`

### `wo_task_request`

**FKs only in Global FM:** `wo_task_request_ibfk_3`

### `wo_task_request_2`

**FKs only in Global FM:** `wo_task_request_2_ibfk_1`

## Common tables with no structural column diffs

69 / 144 common tables have identical column sets/types (by compared fields).

