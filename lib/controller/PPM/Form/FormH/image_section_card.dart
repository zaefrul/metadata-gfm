import 'package:GEMS/utils/reference.dart';
import 'package:flutter/material.dart';
import 'package:GEMS/model/form.dart'; // Assuming FormHItem is here
import 'package:GEMS/main.dart'; // For colorTheme3, colorTheme2

// For UI elegance, we centralize some stylistic constants
const double _kImagePreviewSize = 100.0; // Larger image preview
const double _kCardPadding = 16.0;
const double _kCardElevation = 2.0; // Subtle shadow
const BorderRadius _kCardBorderRadius = BorderRadius.all(Radius.circular(12.0)); // Rounded corners

class ImageSectionCard extends StatelessWidget {
  final String sectionTitle; // e.g., "Image Before", "Image During", "Image After"
  final FormHItem? item; // Null for empty section, populated for filled section
  final bool isDisabled; // Controls interaction enablement
  final ValueChanged<String>? onDescriptionChanged; // Callback for text field changes
  final VoidCallback? onUploadTap; // Callback when "add image" is tapped
  final VoidCallback? onDeleteTap; // Callback for delete button
  final VoidCallback? onImageTap; // Callback when image itself is tapped (e.g., to view full)
  final VoidCallback? onMapTap; // Callback for "show on map" button (if lat/lon available)

  const ImageSectionCard({
    Key? key,
    required this.sectionTitle,
    this.item,
    required this.isDisabled,
    this.onDescriptionChanged,
    this.onUploadTap,
    this.onDeleteTap,
    this.onImageTap,
    this.onMapTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure colors are accessible or map to Theme.of(context) if possible
    final Color primaryColor = AppColors.primary; // Or Theme.of(context).colorScheme.primary
    final Color accentColor = AppColors.accent; // Or Theme.of(context).colorScheme.secondary

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: _kCardElevation,
      shape: RoundedRectangleBorder(borderRadius: _kCardBorderRadius),
      child: Padding(
        padding: const EdgeInsets.all(_kCardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECTION TITLE
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                sectionTitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: primaryColor,
                ),
              ),
            ),
            // IMAGE/UPLOAD AREA
            _buildImageOrUploadArea(context, primaryColor, accentColor),
            const SizedBox(height: 16),
            // DESCRIPTION TEXT FIELD
            TextField(
              controller: TextEditingController(text: item?.ppmTaskUploadDesc ?? ""),
              enabled: !isDisabled,
              decoration: InputDecoration(
                labelText: "Image Description",
                hintText: "Enter description...",
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)), // Slightly rounded border
                ),
                alignLabelWithHint: true, // Labels align with hint for multiline
              ),
              onChanged: onDescriptionChanged,
              maxLines: null, // Allow multiline
              minLines: 3, // Start with at least 3 lines visible
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOrUploadArea(BuildContext context, Color primaryColor, Color accentColor) {
    if (item == null) {
      // EMPTY STATE: Tap to upload
      return GestureDetector(
        onTap: isDisabled ? null : onUploadTap,
        child: Container(
          height: _kImagePreviewSize,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid, width: 2.0),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt, size: 40, color: isDisabled ? Colors.grey : primaryColor),
                const SizedBox(height: 8),
                Text(
                  "Tap to upload image",
                  style: TextStyle(color: isDisabled ? Colors.grey : primaryColor, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // FILLED STATE: Image with details and actions
      final String? src = item!.documentSrc.isNotEmpty
          ? (item!.documentSrc.startsWith("http") ? item!.documentSrc : "http:${item!.documentSrc}")
          : null;
      final bool hasLocation = item!.ppmTaskUploadLatitude != null && item!.ppmTaskUploadLongitude != null &&
                               item!.ppmTaskUploadLatitude != "0.0" && item!.ppmTaskUploadLongitude != "0.0" &&
                               item!.ppmTaskUploadLatitude != "N/A" && item!.ppmTaskUploadLongitude != "N/A";

      return Column(
        children: [
          // IMAGE PREVIEW AREA
          Stack(
            alignment: Alignment.bottomRight, // For timestamp/location
            children: [
              Container(
                width: double.infinity,
                height: _kImagePreviewSize,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                clipBehavior: Clip.antiAlias, // Clip children to rounded corners
                child: src != null
                    ? GestureDetector(
                        onTap: onImageTap, // Allow tapping image to view full
                        child: Image.network(
                          src,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Center(child: Icon(Icons.broken_image, size: 60, color: Colors.grey)),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                                color: accentColor,
                              ),
                            );
                          },
                        ),
                      )
                    : Center(child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey)),
              ),
              // Optional: Overlay for Timestamp/Location (consider if it clutters small images)
              if (item!.ppmTaskUploadTimestamp != null && item!.ppmTaskUploadTimestamp!.isNotEmpty)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item!.ppmTaskUploadTimestamp!,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              if (hasLocation)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text(
                          "GPS", // Simple indicator, full coords in description or dedicated view
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // ACTION BUTTONS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // VIEW FULL IMAGE BUTTON
              if (src != null)
                TextButton.icon(
                  onPressed: onImageTap,
                  icon: const Icon(Icons.zoom_out_map, size: 20),
                  label: const Text("VIEW"),
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              // SHOW ON MAP BUTTON
              if (hasLocation)
                TextButton.icon(
                  onPressed: onMapTap,
                  icon: const Icon(Icons.map, size: 20),
                  label: const Text("MAP"),
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              // DELETE BUTTON
              if (!isDisabled && onDeleteTap != null)
                TextButton.icon(
                  onPressed: onDeleteTap,
                  icon: const Icon(Icons.delete_outline, size: 20),
                  label: const Text("DELETE"),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
        ],
      );
    }
  }
}