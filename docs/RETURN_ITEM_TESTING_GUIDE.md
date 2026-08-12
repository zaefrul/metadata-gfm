# Material Returns Module - Testing Guide

> **Created**: 10 November 2025  
> **Status**: Implementation Complete - Ready for Testing  
> **Backend API**: `https://gems.metadatasystem.my/api/m_inventory.php`

## 🎯 Testing Overview

This guide covers end-to-end testing for the Material Returns Module, including functional workflows, error scenarios, and validation checks.

---

## 📋 Pre-Testing Setup

### Test Users Required
1. **Technician Account** (Role 8)
   - Must have collected materials from storekeeper
   - Check `ast_part_sub` table for status 36 (Parts Collected)
   
2. **Storekeeper Account** (Role 16)
   - Access to storekeeper homepage with badge
   - Permissions to confirm returns

### Test Environment
- **Flutter App**: Build with `flutter run --dart-define=APP_VARIANT=classic`
- **Backend**: Production at `gems.metadatasystem.my`
- **Database**: MySQL with `material_returns` and `ast_part_sub` tables
- **Network**: Stable connection (returns use real-time API calls)

### Verification Tools
- Backend logs for API calls
- MySQL queries to check inventory updates
- Flutter DevTools for stream debugging
- Toast messages for user feedback

---

## ✅ Test Suite 1: Happy Path (Full Workflow)

### Test 1.1: Technician Return Request
**Objective**: Verify technician can view collected items and submit return

**Steps**:
1. Login as technician (role 8)
2. Open side drawer menu
3. Tap "Return Items" menu item
4. **Expected**: Navigate to ReturnItemList screen
5. **Verify**: 
   - Loading indicator shows while fetching
   - List displays items with status 36 (Parts Collected)
   - Each card shows:
     - Part name, code
     - Quantity chips (Collected, In Possession, Available)
     - Work order number
     - Collection date
6. Select an item with available quantity > 0
7. **Expected**: Navigate to ReturnItemDetail form
8. **Verify form displays**:
   - Item info card (read-only)
   - Quantity input (default empty)
   - Reason dropdown (4 options)
   - Optional remarks field
   - Optional deadline picker
   - Submit button enabled

**Test 1.1a: Full Quantity Return**
9. Enter quantity = available quantity
10. Select reason: "Unused / Excess"
11. Enter remarks: "Test full return"
12. Tap Submit button
13. **Expected**: Confirmation dialog appears
14. Confirm in dialog
15. **Expected**:
    - Loading spinner on button
    - Success toast: "Return request submitted successfully!"
    - Navigate back to list
    - Item shows "Pending" badge with orange background
    - Available quantity = 0
16. **Backend verification**:
    - New row in `material_returns` table
    - `returnStatus` = 'pending'
    - `returnRequestDate` populated
    - `ast_part_sub` status unchanged (still 36)

**Test 1.1b: Partial Quantity Return**
17. Select same item again (if had quantity > 1)
18. Enter quantity < available (e.g., 2 out of 5)
19. Select reason: "Wrong Part"
20. Tap Submit
21. **Expected**:
    - Success toast
    - Item still in list with updated available quantity (3)
    - Shows pending badge with quantity (2)
22. **Backend verification**:
    - Second row in `material_returns` table
    - First return still pending
    - `parts_in_possession` remains unchanged

### Test 1.2: Storekeeper Confirm Return
**Objective**: Verify storekeeper can see pending returns and confirm receipt

**Steps**:
1. Login as storekeeper (role 16)
2. Navigate to storekeeper homepage
3. **Verify AppBar badge**:
   - Orange return icon visible
   - Red badge shows count (should match pending returns)
   - Badge shows "1" or "2" from Test 1.1
4. Tap badge icon
5. **Expected**: Navigate to ReturnConfirmList screen
6. **Verify list displays**:
   - Badge count in header matches
   - Each return card shows:
     - Priority color bar (green/orange/red based on age)
     - Part name, code
     - Technician name in blue box
     - Quantity and WO in info chips
     - Reason badge with icon
     - Remarks (if provided)
     - "Time ago" chip
7. Pull down to refresh
8. **Expected**: List reloads, spinner shows briefly
9. Tap first return card
10. **Expected**: Navigate to ReturnConfirmDetail screen
11. **Verify detail displays**:
    - Orange "PENDING CONFIRMATION" status card
    - Item details card (name, code, unit, large quantity)
    - Technician card (name, WO, site)
    - Return info card (reason badge, deadline if set)
    - Remarks card (if provided)
    - Timeline (requested date, no confirmed date yet)
    - Green "Confirm Receipt & Update Inventory" button
12. Tap Confirm button
13. **Expected**: Confirmation dialog appears
14. **Verify dialog**:
    - Warning message about inventory update
    - Shows item, quantity, technician summary
    - Cancel and Confirm buttons
15. Tap "Confirm Receipt"
16. **Expected**:
    - Loading spinner on button
    - Success toast: "Return confirmed successfully!"
    - Navigate back to list
    - List auto-refreshes
    - Confirmed return removed from list
    - Badge count decrements
17. **Backend verification**:
    - `material_returns.returnStatus` = 'completed'
    - `material_returns.returnConfirmedDate` populated
    - `material_returns.storekeeperUserId` set
    - `ast_part_sub.status` = 47 (Returned)
    - `ast_part_sub.quantity_returned` updated
    - `part_locked` decremented (inventory restored)

### Test 1.3: Verify Inventory Update
**MySQL Queries**:
```sql
-- Check return record
SELECT * FROM material_returns 
WHERE returnId = [returned_id];

-- Check part status
SELECT * FROM ast_part_sub 
WHERE wo_task_parts_id = [wo_task_parts_id]
ORDER BY created_at DESC;

-- Check inventory
SELECT part_locked, part_quantity 
FROM ast_part 
WHERE id = [part_id];
```

**Expected Results**:
- Return status = 'completed'
- Part status = 47
- `part_locked` reduced by returned quantity
- `part_quantity` unchanged (still locked to other WOs)

---

## ❌ Test Suite 2: Error Scenarios

### Test 2.1: Invalid Quantity (Exceeds Available)
**Steps**:
1. Login as technician
2. Navigate to Return Items
3. Select item with available = 3
4. Enter quantity = 5
5. Tap Submit
6. **Expected**: Toast error: "Quantity cannot exceed available amount"
7. **Verify**: No API call made, dialog doesn't show

### Test 2.2: Zero Quantity
**Steps**:
1. Enter quantity = 0
2. Tap Submit
3. **Expected**: Toast error: "Please enter a valid quantity"

### Test 2.3: Empty Quantity
**Steps**:
1. Leave quantity field empty
2. Tap Submit
3. **Expected**: Toast error: "Please enter return quantity"

### Test 2.4: Duplicate Pending Return
**Steps**:
1. Submit return for item (creates pending)
2. Try to submit another return for same item
3. Tap Submit
4. **Expected**: 
   - API may reject (check backend logic)
   - Or succeeds and creates second pending
   - Item shows "Pending" badge regardless
5. **Verify**: Check if backend enforces one pending per item

### Test 2.5: Network Error
**Steps**:
1. Turn on Airplane mode
2. Try to submit return
3. **Expected**: 
   - Loading spinner appears
   - Eventually times out
   - Error toast: "Failed to submit return: SocketException..."
4. Turn off Airplane mode
5. Try again
6. **Expected**: Succeeds

### Test 2.6: Session Expiry
**Steps**:
1. Wait for JWT token to expire (~24 hours)
2. Try to access Return Items
3. **Expected**: 
   - API returns 401 or "Expired token"
   - Provider.fetch() catches and shows alert
   - User prompted to re-login

### Test 2.7: Wrong User Role Access
**Steps**:
1. Login as technician
2. Manually navigate to `/return-confirm-list` (if possible)
3. **Expected**: 
   - Backend may return empty list (no permissions)
   - Or 403 error
4. **Note**: Frontend doesn't show storekeeper menu to technicians (UI-level restriction)

---

## 🔄 Test Suite 3: State Management

### Test 3.1: Stream Updates
**Steps**:
1. Login as storekeeper
2. Note badge count
3. Open another device/emulator with technician
4. Technician submits new return
5. Go back to storekeeper device
6. Pull to refresh on pending returns list
7. **Expected**: 
   - Badge count increases
   - New return appears in list
8. Confirm one return
9. **Expected**:
   - Badge count decreases immediately
   - List updates without manual refresh

### Test 3.2: Navigation State Preservation
**Steps**:
1. Navigate to Return Items list
2. Tap item to open detail
3. Tap back button
4. **Expected**: List still shows, no reload
5. Navigate away to homepage
6. Return to Return Items
7. **Expected**: List reloads fresh data

### Test 3.3: BLoC Disposal
**Steps**:
1. Open Return Items (creates BLoC)
2. Navigate back (disposes BLoC)
3. Check Flutter DevTools for memory leaks
4. **Expected**: Streams closed, no lingering subscriptions

---

## 🎨 Test Suite 4: UI/UX Validation

### Test 4.1: Empty States
**Technician - No Collected Items**:
1. Login as technician with no collections
2. Navigate to Return Items
3. **Expected**: 
   - Icon with "No Collected Items" message
   - "You haven't collected any items yet" subtitle

**Storekeeper - No Pending Returns**:
1. Confirm all pending returns
2. Navigate to pending returns list
3. **Expected**:
   - Green check icon
   - "All Caught Up!" message
   - "No pending returns to confirm" subtitle
4. **Verify**: Badge shows 0 or hidden

### Test 4.2: Loading States
**Steps**:
1. Clear app cache
2. Navigate to Return Items
3. **Expected**: Circular progress indicator while loading
4. On slow network, verify spinner shows for duration
5. Tap Submit on return form
6. **Expected**: Button shows spinner, disabled state

### Test 4.3: Pull-to-Refresh
**Steps**:
1. On any list screen, pull down
2. **Expected**: 
   - Spinner appears at top
   - List reloads
   - Updated data displays
3. Verify works on both technician and storekeeper lists

### Test 4.4: Confirmation Dialogs
**Return Submission**:
1. Fill return form
2. Tap Submit
3. **Verify dialog**:
   - Title: "Confirm Return Submission"
   - Shows item, quantity, reason summary
   - Cancel button (gray)
   - Submit button (primary color)
4. Tap Cancel
5. **Expected**: Dialog closes, no API call

**Return Confirmation**:
1. Storekeeper opens detail
2. Tap Confirm button
3. **Verify dialog**:
   - Title: "Confirm Return Receipt"
   - Warning about inventory update
   - Shows item, quantity, technician
   - Cancel and Confirm Receipt buttons
4. Tap outside dialog
5. **Expected**: Dialog closes

### Test 4.5: Toast Messages
**Success Messages**:
- "Return request submitted successfully!"
- "Return confirmed successfully!"

**Error Messages**:
- "Please enter return quantity"
- "Quantity cannot exceed available amount"
- "Failed to load collected items"
- "Failed to confirm return: [error]"

**Verify all toasts**:
- Appear at bottom (Toast.bottom)
- Duration long enough to read
- Don't overlap with UI elements

### Test 4.6: Date Formatting
**Steps**:
1. Check collection date on list cards
2. Check deadline date in detail
3. Check "time ago" chips
4. **Expected formats**:
   - List dates: "dd MMM yyyy" (e.g., "10 Nov 2025")
   - Detail dates: "dd MMM yyyy, HH:mm" (e.g., "10 Nov 2025, 14:30")
   - Time ago: "5m ago", "2h ago", "3d ago", "2w ago"

### Test 4.7: Color Coding
**Priority Indicators (Storekeeper List)**:
- Green bar: < 24 hours old
- Orange bar: 1-3 days old
- Red bar: > 3 days old

**Reason Colors**:
- Unused/Excess: Blue (info)
- Wrong Part: Orange (warning)
- Damaged: Red (danger)
- Other: Gray

**Quantity Chips (Technician List)**:
- Collected: Purple (accent)
- In Possession: Primary blue
- Available: Green (success)

---

## 📊 Test Suite 5: Partial Returns (Batch Scenario)

### Test 5.1: Multi-Stage Return
**Scenario**: Technician collected 10 items, returns in 3 batches

**Batch 1: Return 3 items**:
1. Select item (available = 10)
2. Enter quantity = 3, reason = "Unused"
3. Submit
4. **Verify**:
   - Available = 7
   - Pending badge shows "3 Pending"
   - Can still return more

**Batch 2: Return 5 more items**:
5. Select same item again
6. Enter quantity = 5, reason = "Wrong Part"
7. Submit
8. **Verify**:
   - Available = 2
   - Pending badge shows "8 Pending" (3+5)
   - Two separate pending returns in storekeeper list

**Batch 3: Return remaining 2**:
9. Select item again
10. Enter quantity = 2, reason = "Other"
11. Submit
12. **Verify**:
   - Available = 0
   - "Not Available to Return" gray chip
   - Return button disabled
   - Pending badge shows "10 Pending"

**Storekeeper Confirms All**:
13. Login as storekeeper
14. Badge shows 3 pending returns
15. Confirm first return (3 items)
16. **Verify**: Badge = 2, inventory +3
17. Confirm second return (5 items)
18. **Verify**: Badge = 1, inventory +5
19. Confirm third return (2 items)
20. **Verify**: Badge = 0, inventory +2 (total +10)

**Backend Verification**:
```sql
-- Check all returns for the item
SELECT returnId, quantityReturned, returnStatus, returnReason
FROM material_returns
WHERE woTaskPartsId = [id]
ORDER BY returnRequestDate;

-- Verify final status
SELECT status, quantity_returned 
FROM ast_part_sub
WHERE wo_task_parts_id = [id];
```

**Expected**: All 3 returns status 'completed', total quantity_returned = 10

---

## 🐛 Known Issues & Edge Cases

### Issue 1: Simultaneous Returns
**Scenario**: Two technicians return same item simultaneously
- **Risk**: Race condition on `parts_in_possession`
- **Mitigation**: Backend should use database transactions
- **Test**: Requires two devices/emulators

### Issue 2: Offline Mode
**Current Status**: Not implemented
- Returns require network connection
- No offline queue for return requests
- **Future**: Add to WorkOrder offline queue system

### Issue 3: Image Attachments
**Current Status**: Not implemented
- Returns don't support photos
- Future enhancement per MATERIAL_ITEM_API.md

### Issue 4: Return Rejection
**Current Status**: Not supported
- Storekeepers can only confirm, not reject
- If item damaged/wrong, storekeeper must contact technician outside app

### Issue 5: Return History
**Current Status**: Not exposed in UI
- Backend has `/return_history` endpoint
- Frontend doesn't show completed returns
- **Future**: Add history tab

---

## 📝 Test Reporting Template

```markdown
## Test Execution Report
**Date**: [Date]
**Tester**: [Name]
**Build**: [Flutter build number]
**Backend**: gems.metadatasystem.my

### Test Results
| Test ID | Test Case | Status | Notes |
|---------|-----------|--------|-------|
| 1.1 | Technician Return Request | ✅ Pass | |
| 1.2 | Storekeeper Confirm | ✅ Pass | |
| 1.3 | Inventory Update | ✅ Pass | Verified in DB |
| 2.1 | Invalid Quantity | ❌ Fail | Toast not showing |
| ... | ... | ... | ... |

### Bugs Found
1. **[Bug Title]**
   - Severity: High/Medium/Low
   - Steps to Reproduce: ...
   - Expected: ...
   - Actual: ...
   - Screenshots: [attach]

### Performance Metrics
- API response times: ~200-500ms
- Screen load times: < 2s
- Memory usage: Normal
- Battery impact: Minimal

### Recommendations
- [ ] Fix critical bugs before release
- [ ] Add return history view
- [ ] Implement offline support
- [ ] Add image attachments
```

---

## ✅ Sign-Off Checklist

Before marking testing complete:
- [ ] All happy path scenarios pass
- [ ] Error scenarios handled gracefully
- [ ] UI/UX meets design standards
- [ ] Performance acceptable
- [ ] No memory leaks
- [ ] Backend inventory updates verified
- [ ] Multi-device testing done
- [ ] Different user roles tested
- [ ] Edge cases documented
- [ ] Test report submitted

---

**Testing Status**: 🟡 Ready for QA  
**Last Updated**: 10 November 2025  
**Next Review**: After first round of testing
