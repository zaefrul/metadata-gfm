# PPM API Flow - Complete Sequential API Calls (Without Offline Mode)

**Date**: 12 November 2025  
**Purpose**: Document all API calls from QR scan to task submission in normal (online) flow

---

## Overview

This document lists **ALL API calls** made during a typical PPM task completion flow, from scanning the QR code in Section A through to final submission. This represents the **current implementation without offline mode**.

---

## Complete API Call Sequence

### **Step 1: Open Task from List**
**File**: `lib/controller/PPM/Form/form_view.dart`

| # | API Call | Method | Purpose |
|---|----------|--------|---------|
| 1 | `/ppm_v2/ppm_section_status/{ppmTaskId}` | GET | Load all 9 section statuses + metadata |

**Response includes**:
- `statusList[]` - Status of all 9 sections (A-H + I)
- `checkParts` - Section E status
- `checkAdditionalReport` - Section F status
- `ppmTaskTimeStart` - Task start time (if already started)
- `ppmTaskTimeServiced` - Task end time (if completed)

---

### **Step 2: Section A - Asset Details & QR Scan**
**File**: `lib/controller/PPM/Form/formA.dart`

| # | API Call | Method | Purpose |
|---|----------|--------|---------|
| 2 | `/api/m_ppm.php?type=ppm_section_a&ppmTaskId={id}` | GET | Load asset details |

**Response includes**:
- Asset info (group, category, type, brand, model, capacity, assetNo)
- Location details
- PM start/end times

**After scanning QR code successfully**:

| # | API Call | Method | Purpose |
|---|----------|--------|---------|
| 3 | `/api/m_ppm.php` | POST | Save start time + verify QR scan |

**POST Body**:
```json
{
  "action": "save_scan_start_time",
  "ppmTaskId": "2123029"
}
```

---

### **Step 3: Section B - Safety Precaution**
**File**: `lib/controller/PPM/Form/formB.dart`

| # | API Call | Method | Purpose |
|---|----------|--------|---------|
| 4 | `/api/m_ppm.php?type=ppm_section_b&ppmTaskId={id}` | GET | Load safety guidelines (read-only) |

**No POST** - This section is read-only

---

### **Step 4: Section C - Qualitative Tasks**
**File**: `lib/controller/PPM/Form/formC.dart`

| # | API Call | Method | Purpose |
|---|----------|--------|---------|
| 5 | `/api/m_ppm.php?type=ppm_section_c&ppmTaskId={id}` | GET | Load qualitative checklist items |

**Response includes**:
- List of qualitative tasks (`ppmTaskQual[]`)
- Each task has: `ppmTaskQId`, `ppmTaskQNumb`, `ppmTaskQDesc`, `frequencyName`

**When saving all qualitative tasks**:

| # | API Call | Method | Purpose |
|---|----------|--------|---------|
| 6 | `/api/m_ppm.php` | POST | Save all qualitative task results |

**POST Body Example**:
```json
{
  "action": "save_qualitative_tasks",
  "ppmTaskId": "2123029",
  "ppmTaskQual[0][id]": "7753796",
  "ppmTaskQual[0][result]": "1",
  "ppmTaskQual[0][remark]": "All systems operational"
}
```

---

### **Step 5: Section D - Quantitative Tasks**
**File**: `lib/controller/PPM/Form/formD.dart`

| # | API Call | Method | Purpose |
|---|----------|--------|---------|
| 7 | `/api/m_ppm.php?type=ppm_section_d&ppmTaskId={id}` | GET | Load quantitative measurement tasks |

**Response includes**:
- List of quantitative tasks (`ppmTaskQuan[]`)
- Each task has: `ppmTaskQuanId`, `ppmTaskQuanDesc`, `ppmTaskQuanUnit`, `ppmTaskQuanSetValues`

**When saving all quantitative tasks**:

| # | API Call | Method | Purpose |
|---|----------|--------|---------|
| 8 | `/api/m_ppm.php` | POST | Save all quantitative task measurements |

**POST Body Example**:
```json
{
  "action": "save_quantitative_tasks",
  "ppmTaskId": "2123029",
  "ppmTaskQuan[0][id]": "7753798",
  "ppmTaskQuan[0][setValues]": "50",
  "ppmTaskQuan[0][measuredValues]": "48.5",
  "ppmTaskQuan[0][limit]": "45-55",
  "ppmTaskQuan[0][result]": "1",
  "ppmTaskQuan[0][remark]": "Within tolerance"
}
```

---

### **Step 6: Section E - Spare Parts Check**
**File**: `lib/controller/PPM/Form/formE.dart`

| # | API Call | Method | Purpose |
|---|----------|--------|---------|
| 9 | `/api/m_ppm.php?type=ppm_section_e&ppmTaskId={id}` | GET | Load spare parts list (if applicable) |

**When user checks "Yes" or "No" for spare parts used**:

| # | API Call | Method | Purpose |
|---|----------|--------|---------|
| 10 | `/api/m_ppm.php` | POST | Save spare parts status |

**POST Body Example** (No parts):
```json
{
  "action": "check_ppm_parts",
  "ppmTaskId": "2123029",
  "status": "0",
  "spareParts": ""
}
```

**POST Body Example** (Parts used):
```json
{
  "action": "check_ppm_parts",
  "ppmTaskId": "2123029",
  "status": "1",
  "spareParts": "Filter,Belt,Oil"
}
```

---

### **Step 7: Section F - Additional Report**
**File**: `lib/controller/PPM/Form/formF.dart`

| # | API Call | Method | Purpose |
|---|----------|--------|---------|
| 11 | `/api/m_ppm.php?type=ppm_section_f&ppmTaskId={id}` | GET | Load additional report images (if any) |

**When user checks "Yes" or "No" for additional report**:

| # | API Call | Method | Purpose |
|---|----------|--------|---------|
| 12 | `/api/m_ppm.php` | POST | Save additional report status |

**POST Body Example** (No report):
```json
{
  "action": "check_additional_report",
  "ppmTaskId": "2123029",
  "status": "0"
}
```

**When user uploads additional report images**:

| # | API Call | Method | Purpose |
|---|----------|--------|---------|
| 13 | `/api/m_ppm.php` | POST | Upload each additional report image |

**POST Body Example** (per image):
```json
{
  "action": "upload_additional_report",
  "ppmTaskId": "2123029",
  "ppmTaskUploadType": "Additional",
  "fileUpload[name]": "report_image_1",
  "fileUpload[filename]": "IMG_20251112_1430.jpg",
  "fileUpload[size]": "1024000",
  "fileUpload[type]": "image/jpeg",
  "fileUpload[data]": "base64_encoded_image_data",
  "latitude": "3.1390",
  "longitude": "101.6869",
  "imageDesc": "Additional findings"
}
```

---

### **Step 8: Section G - Remark**
**File**: `lib/controller/PPM/Form/formG.dart`

| # | API Call | Method | Purpose |
|---|----------|--------|---------|
| 14 | `/api/m_ppm.php?type=ppm_section_g&ppmTaskId={id}` | GET | Load existing remark (if any) |

**When user saves remark**:

| # | API Call | Method | Purpose |
|---|----------|--------|---------|
| 15 | `/api/m_ppm.php` | POST | Save/update remark text |

**POST Body Example**:
```json
{
  "action": "save_ppm_remark",
  "ppmTaskId": "2123029",
  "ppmTaskRemark": "All tasks completed satisfactorily. No major issues found."
}
```

---

### **Step 9: Section H - Maintenance Images**
**File**: `lib/controller/PPM/Form/formH.dart`

| # | API Call | Method | Purpose |
|---|----------|--------|---------|
| 16 | `/api/m_ppm.php?type=ppm_section_h&ppmTaskId={id}` | GET | Load existing maintenance images |

**Response includes**:
- `sectionHList[]` - Array of images categorized by type
  - `ppmTaskUploadType`: "Before", "During", "After"
  - `ppmTaskUploadId`, `uploadId`, `uploadName`, `documentSrc`
  - `ppmTaskUploadLatitude`, `ppmTaskUploadLongitude`, `ppmTaskUploadTimestamp`
  - `ppmTaskUploadDesc` - Image description

**When user uploads EACH maintenance image** (3 required: Before, During, After):

| # | API Call | Method | Purpose |
|---|----------|--------|---------|
| 17 | `/api/m_ppm.php` | POST | Upload "Before" image |
| 18 | `/api/m_ppm.php` | POST | Upload "During" image 1 |
| 19 | `/api/m_ppm.php` | POST | Upload "During" image 2 |
| 20 | `/api/m_ppm.php` | POST | Upload "During" image 3 |
| 21 | `/api/m_ppm.php` | POST | Upload "After" image |

**POST Body Example** (per image):
```json
{
  "action": "upload_ppm_image",
  "ppmTaskId": "2123029",
  "ppmTaskUploadType": "Before",
  "fileUpload[name]": "maintenance_before",
  "fileUpload[filename]": "IMG_20251112_0900.jpg",
  "fileUpload[size]": "2048000",
  "fileUpload[type]": "image/jpeg",
  "fileUpload[data]": "base64_encoded_image_data",
  "latitude": "3.1390",
  "longitude": "101.6869",
  "imageDesc": "Asset condition before maintenance"
}
```

**When user updates image descriptions** (if needed):

| # | API Call | Method | Purpose |
|---|----------|--------|---------|
| 22 | `/api/m_ppm.php` | POST | Save all image descriptions in one call |

**POST Body Example**:
```json
{
  "action": "save_image_descriptions",
  "ppmTaskId": "2123029",
  "imageDesc[0][id]": "upload_id_1",
  "imageDesc[0][desc]": "Updated description",
  "imageDesc[1][id]": "upload_id_2",
  "imageDesc[1][desc]": "Another description"
}
```

---

### **Step 10: Final Submission**
**File**: `lib/controller/PPM/Form/pdf.dart`

**Before submitting, system calls refresh to verify all sections complete**:

| # | API Call | Method | Purpose |
|---|----------|--------|---------|
| 23 | `/ppm_v2/ppm_section_status/{ppmTaskId}` | GET | Re-check all section statuses before submit |

**When user clicks "Submit" button**:

| # | API Call | Method | Purpose |
|---|----------|--------|---------|
| 24 | `/api/m_ppm.php` | POST | Submit PPM task to workflow |

**POST Body Example**:
```json
{
  "action": "submit_ppm",
  "ppmTaskId": "2123029",
  "checkpoint": "1",
  "result": "2",
  "remark": "Task completed successfully",
  "fileUpload[name]": "",
  "fileUpload[filename]": "",
  "fileUpload[size]": "",
  "fileUpload[type]": "",
  "fileUpload[data]": ""
}
```

**Checkpoint values**:
- `1` = Submit from "In Progress" → "Check" (Technician completes)
- `2` = Submit from "Check" → "Verify" (Supervisor checks)
- `3` = Submit from "Verify" → "Closed" (Verifier approves)

**Result values**:
- `1` = Reject (send back)
- `2` = Approve (move forward)

---

## Summary Statistics

### Total API Calls (Typical Flow)

| Category | Count | Notes |
|----------|-------|-------|
| **Initial Load** | 1 | Section status overview |
| **Section Data GETs** | 8 | Load data for sections A-H |
| **QR Scan POST** | 1 | Start time + verification |
| **Task Data POSTs** | 2 | Qualitative + Quantitative saves |
| **Checkbox POSTs** | 2 | Spare parts + Additional report checks |
| **Image Uploads** | 5-10 | Before/During/After + optional additional |
| **Remark POST** | 1 | Save remark text |
| **Image Description POST** | 0-1 | Only if descriptions updated |
| **Pre-submit Refresh** | 1 | Final status check |
| **Final Submit POST** | 1 | Workflow submission |
| **TOTAL** | **22-30 calls** | Depends on image count |

### Time Breakdown (Current Sequential Flow)

| Operation | Time (seconds) | Notes |
|-----------|----------------|-------|
| Initial section load | 2-3 | 1 API call |
| Load all section data | 16-24 | 8 API calls @ 2-3s each |
| Save qualitative tasks | 2-3 | 1 API call |
| Save quantitative tasks | 2-3 | 1 API call |
| Save spare parts check | 2-3 | 1 API call |
| Save additional report check | 2-3 | 1 API call |
| Upload 5 images | 15-25 | 5 API calls @ 3-5s each |
| Save remark | 2-3 | 1 API call |
| Pre-submit refresh | 2-3 | 1 API call |
| Final submit | 2-3 | 1 API call |
| **TOTAL** | **48-72 seconds** | Assumes no retries |

### With Network Issues or Retries

| Scenario | Time Range | Notes |
|----------|------------|-------|
| **Ideal conditions** | 48-72s | As above |
| **Slow 3G connection** | 90-150s | 2-3x slower |
| **With retries (3 images fail once)** | 60-90s | +12-18s for retries |
| **Worst case (multiple retries)** | 120-180s | Multiple sections retry |

---

## API Endpoint Reference

### Base URLs

```
Primary:   https://gems.metadatasystem.my/api/m_ppm.php
Section Status: https://gems.metadatasystem.my/ppm_v2/ppm_section_status/{id}
```

### Common Parameters

**Headers**:
```
Authorization: Bearer {jwt_token}
deviceid: {device_uuid}
Content-Type: application/x-www-form-urlencoded  (for form data)
```

**Query Parameters** (GET):
- `type` - Section identifier (e.g., `ppm_section_a`)
- `ppmTaskId` - Task identifier

**POST Body Keys**:
- `action` - Action type (see Actions table below)
- `ppmTaskId` - Always required
- Section-specific fields

---

## Action Types Reference

| Action | Used In | Purpose |
|--------|---------|---------|
| `save_scan_start_time` | Section A | Record task start + QR verification |
| `save_qualitative_tasks` | Section C | Save all qualitative checklist results |
| `save_quantitative_tasks` | Section D | Save all quantitative measurements |
| `check_ppm_parts` | Section E | Save spare parts usage status |
| `check_additional_report` | Section F | Save additional report status |
| `upload_additional_report` | Section F | Upload additional report images |
| `save_ppm_remark` | Section G | Save/update remark text |
| `upload_ppm_image` | Section H | Upload maintenance images (Before/During/After) |
| `save_image_descriptions` | Section H | Update image descriptions (optional) |
| `submit_ppm` | Submit | Final workflow submission |

---

## Key Findings

### Problems with Current Flow

1. **Sequential API Calls**: All 22-30 calls happen one after another
2. **No Batching**: Each action requires separate round-trip to server
3. **Image Uploads Most Expensive**: 5-10 images @ 3-5s each = 15-50 seconds
4. **Redundant Status Checks**: Load section status twice (initial + pre-submit)
5. **No Offline Support**: Lose all progress if connection drops mid-task
6. **No Retry Logic**: Failed uploads require manual retry by user
7. **No Idempotency**: Re-submitting same action may create duplicates

### Batch Sync Improvements

**With batch sync API** (as per `API_PPM_OFFLINE_DOC.md`):
- All 10-15 data save actions → **1 API call**
- Time reduction: **48-72s → 3-5s** (10-20x faster)
- Idempotency: Duplicate sync detection via `actionId`
- Atomic transactions: All-or-nothing per action type
- Immediate feedback: Submission readiness in response

**Image uploads still separate** (reasonable):
- Images remain individual POST calls (size constraints)
- But can retry independently without re-sending data actions

---

## Next Steps for Backend Team

Based on this analysis, the backend needs to:

1. ✅ **Read JSON POST data** from `php://input` (not `$_POST`)
2. ✅ **Implement batch sync endpoint** (`action=batch_sync_offline_actions`)
3. ✅ **Support all action types** listed in `Action Types Reference` table above
4. ⚠️ **Maintain backward compatibility** with individual action endpoints (for old app versions)
5. ⚠️ **Add idempotency** checks using `actionId` field (prevent duplicate processing)

---

## Related Documents

- `API_PPM_OFFLINE_DOC.md` - Backend batch sync API specification
- `BACKEND_FIX_REQUIRED.md` - Current JSON POST issue and fix
- `PPM_OFFLINE_BATCH_SYNC_API.md` - Original batch sync design proposal

---

**Last Updated**: 12 November 2025  
**Maintainer**: GEMS Mobile Team
