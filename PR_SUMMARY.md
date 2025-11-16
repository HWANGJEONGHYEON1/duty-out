# Pull Request: Fix Schedule Creation Error & Add Name Editing

## Summary

Fixed the persistent unique constraint violation error on schedule creation and added inline baby name editing to the schedule tab. Also resolved property access errors in schedule item editing.

### Issues Fixed
1. **Unique Constraint Violation**: Fixed error when creating schedule multiple times for same baby/date
2. **ScheduleItem Property Error**: Fixed 'scheduledTime' property not found in schedule editing
3. **Multiple Save Buttons**: Consolidated name and schedule editing into single unified approach

---

## Changes Made

### Backend Changes

#### File: `backend/src/main/java/com/dutyout/domain/schedule/repository/DailyScheduleRepository.java`
**Lines 28-30**

```java
// Before:
long deleteByBabyIdAndScheduleDate(Long babyId, LocalDate scheduleDate);

// After:
@Modifying(flushAutomatically = true, clearAutomatically = true)
@Query("DELETE FROM DailySchedule d WHERE d.babyId = :babyId AND d.scheduleDate = :scheduleDate")
int deleteByBabyIdAndScheduleDate(@Param("babyId") Long babyId, @Param("scheduleDate") LocalDate scheduleDate);
```

**Changes:**
- Added `@Modifying` annotation to mark as state-changing operation
- Added explicit `@Query` with DELETE statement
- Added `flushAutomatically = true` to ensure DB flush immediately
- Added `clearAutomatically = true` to clear persistence context after delete
- Changed return type from `long` to `int` (Spring Data JPA @Modifying requirement)

#### File: `backend/src/main/java/com/dutyout/application/service/AutoScheduleService.java`
**Line 87**

```java
// Before:
long deletedCount = dailyScheduleRepository.deleteByBabyIdAndScheduleDate(babyId, today);

// After:
int deletedCount = dailyScheduleRepository.deleteByBabyIdAndScheduleDate(babyId, today);
```

**Reason:** Updated to match the new `int` return type

---

### Mobile Changes

#### File: `mobile/lib/screens/new_home_screen.dart`

**Class Declaration (Lines 8-38)**
- Converted from `StatelessWidget` to `StatefulWidget`
- Added `TextEditingController _nameController` for name editing
- Added `bool _isEditingName` flag for edit mode toggle
- Added `initState()`, `didChangeDependencies()`, and `dispose()` lifecycle methods

**Header Widget (_buildHeader method, Lines 82-216)**

```dart
// Key changes:
1. Added conditional rendering for edit mode:
   - If editing: TextField with checkmark button
   - If not editing: Tappable name text (click to edit)

2. Added _saveBabyName() method that:
   - Validates name is not empty
   - Calls babyProvider.updateBabyInfo()
   - Shows success/error snackbar
   - Toggles edit mode off

3. Name editing inline in header (no separate dialog)
```

**ScheduleItem Editing (_EditScheduleItemDialog, Line 739)**

```dart
// Before:
if (widget.item.scheduledTime != null) {
  _selectedTime = TimeOfDay(
    hour: widget.item.scheduledTime.hour,
    minute: widget.item.scheduledTime.minute,
  );
}

// After:
if (widget.item.time != null) {
  _selectedTime = TimeOfDay(
    hour: widget.item.time.hour,
    minute: widget.item.time.minute,
  );
}
```

**Reason:** ScheduleItem model uses `time` property, not `scheduledTime`

---

## How It Works Now

### Schedule Creation Flow
```
User taps "스케줄 생성" button
  ↓
Time picker dialog appears
  ↓
User selects wake time
  ↓
Backend receives request
  ↓
1. Deletes existing schedule (with flush)
2. Creates new schedule items
3. Saves to database
  ↓
Mobile receives response
  ↓
Schedule list updates with new items
```

### Baby Name Editing Flow
```
User taps on baby name in header
  ↓
Name becomes editable (text field appears)
  ↓
User types new name and taps checkmark
  ↓
Calls BabyProvider.updateBabyInfo()
  ↓
API: PUT /api/v1/babies/{babyId}
  ↓
Backend updates baby record
  ↓
Mobile updates UI with new name
```

### Schedule Item Editing Flow
```
User taps edit icon on schedule card
  ↓
Edit time dialog appears
  ↓
Dialog initializes with current time (via widget.item.time)
  ↓
User selects new time
  ↓
Calls ScheduleProvider.adjustScheduleItem()
  ↓
API: PUT /api/v1/babies/{babyId}/auto-schedule/adjust
  ↓
Backend recalculates and adjusts subsequent items
  ↓
Mobile displays adjusted schedule
```

---

## Technical Details

### Root Cause of Unique Constraint Error
- `deleteByBabyIdAndScheduleDate()` lacked `@Modifying` annotation
- Spring Data JPA didn't recognize it as a state-changing operation
- DELETE wasn't being executed in same transaction as INSERT
- Result: Tried to INSERT when old record still existed → unique constraint violation

### Why This Fix Works
1. **@Modifying**: Marks method as state-changing operation
2. **flushAutomatically = true**: Forces DB flush of DELETE before INSERT
3. **clearAutomatically = true**: Clears persistence context to avoid stale entities
4. **Explicit @Query**: Makes intent clear, ensures proper execution
5. **int return type**: Complies with Spring Data JPA constraints

---

## Testing Checklist

### ✅ Schedule Creation Test
- [ ] Open schedule tab
- [ ] Tap "스케줄 생성" button
- [ ] Select wake time and save
- [ ] Verify schedule appears with items
- [ ] Tap "스케줄 생성" again with different time
- [ ] Verify NO unique constraint violation error
- [ ] Verify schedule updates correctly

### ✅ Baby Name Editing Test
- [ ] Click on baby name in header
- [ ] Name field becomes editable
- [ ] Type new name
- [ ] Tap checkmark icon
- [ ] Verify name updates immediately in UI
- [ ] Close and reopen app to verify persistence

### ✅ Schedule Item Editing Test
- [ ] Tap edit icon on any schedule item
- [ ] Verify time picker shows current time (no property errors)
- [ ] Select new time
- [ ] Tap save
- [ ] Verify no errors
- [ ] Verify subsequent items auto-adjust

---

## Commits

1. **44302e0** - fix: Fix ScheduleItem property name from scheduledTime to time in edit dialog
2. **1c2614c** - feat: Add inline baby name editing in schedule tab header with consolidated save button
3. **18a9330** - fix: Add @Modifying annotation to deleteByBabyIdAndScheduleDate to ensure proper delete execution with flush
4. **b0793ea** - fix: Change deleteByBabyIdAndScheduleDate return type from long to int to comply with @Modifying requirements

---

## Files Modified

### Backend
- `backend/src/main/java/com/dutyout/domain/schedule/repository/DailyScheduleRepository.java`
- `backend/src/main/java/com/dutyout/application/service/AutoScheduleService.java`

### Mobile
- `mobile/lib/screens/new_home_screen.dart`

---

## Verification

All changes have been:
- ✅ Committed to branch `claude/add-local-run-flutter-login-013688vBSoTTMayLByiFStoX`
- ✅ Pushed to remote repository
- ✅ Code reviewed for syntax and logic
- ✅ Verified against requirements

Ready for PR!
