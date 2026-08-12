#!/usr/bin/env python3
"""Fix offline_database.dart by adding missing methods."""

def fix_file():
    file_path = 'lib/data/local/offline_database.dart'
    
    with open(file_path, 'r') as f:
        lines = f.readlines()
    
    # Find and fix getPPMPendingActions
    for i, line in enumerate(lines):
        if 'Future<List<PPMPendingActionEntity>> getPPMPendingActions() async {' in line:
            # Replace the method signature and implementation
            # Find the end of this method (next method or closing brace)
            method_start = i
            brace_count = 0
            method_end = i
            
            for j in range(i, len(lines)):
                if '{' in lines[j]:
                    brace_count += lines[j].count('{')
                if '}' in lines[j]:
                    brace_count -= lines[j].count('}')
                    if brace_count == 0:
                        method_end = j
                        break
            
            # Replace with new implementation
            new_method = '''  Future<List<PPMPendingActionEntity>> getPPMPendingActions({
    String? ppmTaskId,
  }) async {
    final db = await database;
    final rows = await db.query(
      _PPMPendingActionsTable.tableName,
      where: ppmTaskId != null ? 'ppm_task_id = ?' : null,
      whereArgs: ppmTaskId != null ? [ppmTaskId] : null,
      orderBy: 'created_at ASC',
    );
    return rows.map(PPMPendingActionEntity.fromMap).toList();
  }
'''
            lines[method_start:method_end+1] = [new_method]
            break
    
    # Now find where to insert savePPMSectionData (after loadPPMSectionData)
    for i, line in enumerate(lines):
        if 'Future<String?> loadPPMSectionData' in line:
            # Find the end of this method
            brace_count = 0
            method_end = i
            
            for j in range(i, len(lines)):
                if '{' in lines[j]:
                    brace_count += lines[j].count('{')
                if '}' in lines[j]:
                    brace_count -= lines[j].count('}')
                    if brace_count == 0:
                        method_end = j
                        break
            
            # Insert savePPMSectionData after this method
            new_method = '''
  /// Save/Update section data for a specific section
  Future<void> savePPMSectionData({
    required String ppmTaskId,
    required String sectionName,
    required String sectionData,
  }) async {
    final db = await database;
    
    // Check if section exists
    final existing = await db.query(
      _PPMSnapshotSectionsTable.tableName,
      where: 'ppm_task_id = ? AND section_name = ?',
      whereArgs: [ppmTaskId, sectionName],
      limit: 1,
    );

    if (existing.isEmpty) {
      // Insert new section
      await db.insert(
        _PPMSnapshotSectionsTable.tableName,
        {
          'ppm_task_id': ppmTaskId,
          'section_name': sectionName,
          'section_data': sectionData,
          'section_status': '',
          'check_parts': '',
          'check_additional_report': '',
        },
      );
    } else {
      // Update existing section
      await db.update(
        _PPMSnapshotSectionsTable.tableName,
        {'section_data': sectionData},
        where: 'ppm_task_id = ? AND section_name = ?',
        whereArgs: [ppmTaskId, sectionName],
      );
    }
  }
'''
            lines.insert(method_end + 1, new_method)
            break
    
    # Write back
    with open(file_path, 'w') as f:
        f.writelines(lines)
    
    print("Fixed offline_database.dart:")
    print("- Updated getPPMPendingActions() to include optional ppmTaskId parameter")
    print("- Added savePPMSectionData() method")

if __name__ == '__main__':
    fix_file()
