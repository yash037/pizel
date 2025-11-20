from ultralytics import YOLO
import cv2
import numpy as np
import matplotlib.pyplot as plt
from scipy.ndimage import rotate
import os


def order_points(pts):
    rect = np.zeros((4, 2), dtype="float32")
    s = pts.sum(axis=1)
    rect[0] = pts[np.argmin(s)]   # top-left
    rect[2] = pts[np.argmax(s)]   # bottom-right

    diff = np.diff(pts, axis=1)
    rect[1] = pts[np.argmin(diff)]  # top-right
    rect[3] = pts[np.argmax(diff)]  # bottom-left
    return rect


def enhanced_four_point_transform(image, pts):
    """Improved perspective transform that forces perfect rectangle"""
    # Use the perfect rectangle transform instead of the original
    return perfect_rectangle_transform(image, pts)

def find_best_contour(cropped_image):
    """Find the best document contour with multiple fallback methods"""
    gray = cv2.cvtColor(cropped_image, cv2.COLOR_BGR2GRAY)
    
    # Method 1: Multi-level thresholding for better edge detection
    blur = cv2.GaussianBlur(gray, (5, 5), 0)
    
    # Try multiple threshold methods
    thresh_methods = []
    
    # Otsu's threshold
    _, thresh_otsu = cv2.threshold(blur, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    thresh_methods.append(thresh_otsu)
    
    # Adaptive threshold
    thresh_adapt = cv2.adaptiveThreshold(blur, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, 
                                        cv2.THRESH_BINARY, 11, 2)
    thresh_methods.append(thresh_adapt)
    
    # Canny edge detection
    edges = cv2.Canny(blur, 50, 150)
    thresh_methods.append(edges)
    
    best_contour = None
    best_score = 0
    
    for thresh in thresh_methods:
        # Morphological operations to clean up the image
        kernel = np.ones((5, 5), np.uint8)
        thresh = cv2.morphologyEx(thresh, cv2.MORPH_CLOSE, kernel)
        thresh = cv2.morphologyEx(thresh, cv2.MORPH_OPEN, kernel)
        
        cnts, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        
        if not cnts:
            continue
            
        # Sort by area and check top contours
        cnts = sorted(cnts, key=cv2.contourArea, reverse=True)[:3]
        
        for cnt in cnts:
            area = cv2.contourArea(cnt)
            if area < 1000:  # Minimum area threshold
                continue
                
            # Calculate contour score based on area and rectangularity
            peri = cv2.arcLength(cnt, True)
            approx = cv2.approxPolyDP(cnt, 0.02 * peri, True)
            
            # Score based on rectangularity and number of vertices
            rectangularity = area / (peri * peri / 16) if peri > 0 else 0
            vertex_score = 1 - min(abs(len(approx) - 4), 4) / 4  # Prefer 4 vertices
            
            score = area * rectangularity * vertex_score
            
            if score > best_score:
                best_score = score
                best_contour = approx if len(approx) >= 4 else cnt
    
    return best_contour

def apply_filter(image, mode="original"):
    """
    Apply different filters to the scanned image.
    mode options: "original", "bw", "lighttext", "gray"
    """
    if mode == "original":
        return image

    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    if mode == "bw":
        # Black & White using adaptive threshold
        return cv2.adaptiveThreshold(
            gray, 255, cv2.ADAPTIVE_THRESH_MEAN_C,
            cv2.THRESH_BINARY, 15, 15
        )

    elif mode == "lighttext":
        # Enhance faint/light text
        inv = cv2.bitwise_not(gray)
        norm = cv2.normalize(inv, None, 0, 255, cv2.NORM_MINMAX)
        return cv2.bitwise_not(norm)

    elif mode == "gray":
        return gray

    else:
        raise ValueError(f"Unknown filter mode: {mode}")

def refine_edges(image, points, margin=10):
    """Refine the selected points using edge detection"""
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    edges = cv2.Canny(gray, 50, 150)
    
    refined_points = []
    for point in points:
        x, y = point
        # Search in a small area around the selected point
        roi = edges[y-margin:y+margin, x-margin:x+margin]
        
        # Find the strongest edge in this region
        indices = np.where(roi > 0)
        if len(indices[0]) > 0:
            refined_y = y - margin + np.mean(indices[0]).astype(int)
            refined_x = x - margin + np.mean(indices[1]).astype(int)
            refined_points.append([refined_x, refined_y])
        else:
            refined_points.append(point)
    
    return np.array(refined_points, dtype=np.float32)

def ensure_perfect_rectangle(points, target_width, target_height):
    """Force the output to be a perfect rectangle"""
    # Calculate current dimensions
    width_top = np.linalg.norm(points[1] - points[0])
    width_bottom = np.linalg.norm(points[2] - points[3])
    height_left = np.linalg.norm(points[3] - points[0])
    height_right = np.linalg.norm(points[2] - points[1])
    
    # Use average dimensions
    avg_width = int((width_top + width_bottom) / 2)
    avg_height = int((height_left + height_right) / 2)
    
    # Create perfect rectangle points
    perfect_points = np.array([
        [0, 0],
        [avg_width, 0],
        [avg_width, avg_height],
        [0, avg_height]
    ], dtype=np.float32)
    
    return perfect_points, avg_width, avg_height

def fix_rotation(image):
    """Improved rotation fix with offset for better straightening"""
    if len(image.shape) == 3:
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    else:
        gray = image.copy()
    
    # Enhanced edge detection for documents
    blur = cv2.GaussianBlur(gray, (5, 5), 0)
    edges = cv2.Canny(blur, 50, 150)
    
    # Detect lines with higher threshold for cleaner detection
    lines = cv2.HoughLines(edges, 1, np.pi/180, threshold=150)
    
    if lines is not None:
        horizontal_angles = []
        vertical_angles = []
        
        for rho, theta in lines[:, 0]:
            angle = np.degrees(theta)
            
            # Classify as horizontal (around 0° or 180°) or vertical (around 90°)
            if abs(angle) < 30 or abs(angle - 180) < 30:
                # Horizontal lines
                if angle > 90:
                    angle = angle - 180  # Convert to -90 to 90 range
                horizontal_angles.append(angle)
            elif abs(angle - 90) < 30:
                # Vertical lines
                vertical_angles.append(angle - 90)  # Convert to -90 to 90 range
        
        # Prefer horizontal lines for document straightening
        if horizontal_angles:
            # Use median for better outlier rejection
            median_angle = np.median(horizontal_angles)
            angle_std = np.std(horizontal_angles)
            
            print(f"📐 Detected tilt: {median_angle:.2f}° (std: {angle_std:.2f})")
            
            # Only rotate if:
            # 1. Angle is significant enough (> 0.3 degrees)
            # 2. Angle is reasonable (< 15 degrees) - documents rarely tilt more
            # 3. Lines are consistent (low standard deviation)
            if (0.3 < abs(median_angle) < 15.0 and 
                angle_std < 10.0 and  # Good line consistency
                len(horizontal_angles) >= 3):  # Enough lines detected
                
                # Apply offset/margin for better straightening
                final_angle = apply_straightening_offset_simple(median_angle)
                
                (h, w) = image.shape[:2]
                center = (w // 2, h // 2)
                M = cv2.getRotationMatrix2D(center, final_angle, 1.0)
                rotated = cv2.warpAffine(image, M, (w, h), flags=cv2.INTER_CUBIC,
                                       borderMode=cv2.BORDER_REPLICATE)
                print(f"🔄 Applied rotation: {median_angle:.1f}° → {final_angle:.1f}°")
                return rotated
            else:
                if abs(median_angle) >= 15.0:
                    print("⚠️  Tilt too large, likely perspective issue - skipping rotation")
                elif angle_std >= 10.0:
                    print("⚠️  Inconsistent lines detected - skipping rotation")
                else:
                    print("✅ Image already straight enough")
        else:
            print("📄 No strong horizontal lines found - likely already straight")
    
    else:
        print("📄 No lines detected - image may be already straight or low contrast")
    
    return image

def apply_straightening_offset_simple(angle):
    """Simple proportional offset"""
    abs_angle = abs(angle)
    
    # Add 10-15% overcorrection
    offset_ratio = 0.12  # 12% overcorrection
    offset = abs_angle * offset_ratio
    
    if angle > 0:
        return angle + offset
    else:
        return angle - offset

def auto_rotate_to_horizontal(image):
    """Automatically rotate image to make text/document horizontal"""
    if len(image.shape) == 3:
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    else:
        gray = image.copy()
    
    # Apply Gaussian blur
    blur = cv2.GaussianBlur(gray, (5, 5), 0)
    
    # Use Otsu's threshold
    _, thresh = cv2.threshold(blur, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    
    # Get the coordinates of all non-zero pixels
    coords = np.column_stack(np.where(thresh > 0))
    
    if len(coords) < 5:  # Not enough points to calculate angle
        return image
    
    # Calculate minimum area rectangle
    rect = cv2.minAreaRect(coords)
    angle = rect[-1]
    
    # Adjust angle to make it horizontal
    if angle < -45:
        angle = -(90 + angle)
    else:
        angle = -angle
    
    # Only rotate if angle is significant enough
    if abs(angle) > 1.0:
        (h, w) = image.shape[:2]
        center = (w // 2, h // 2)
        M = cv2.getRotationMatrix2D(center, angle, 1.0)
        rotated = cv2.warpAffine(image, M, (w, h), flags=cv2.INTER_CUBIC, 
                                borderMode=cv2.BORDER_REPLICATE)
        print(f"🔄 Auto-rotated by {angle:.2f} degrees")
        return rotated
    
    return image

def balanced_straighten(image):
    """Balanced straightening - gentle corrections for all tilt sizes"""
    if len(image.shape) == 3:
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    else:
        gray = image.copy()
    
    # Balanced edge detection
    blur = cv2.GaussianBlur(gray, (5, 5), 0)
    edges = cv2.Canny(blur, 50, 150)  # Balanced thresholds
    
    # Reasonable threshold for line detection
    lines = cv2.HoughLines(edges, 1, np.pi/180, threshold=120)
    
    if lines is not None:
        angles = []
        for rho, theta in lines[:, 0]:
            angle = np.degrees(theta) - 90
            # Moderate range
            if -15 <= angle <= 15:
                angles.append(angle)
        
        if angles and len(angles) >= 4:  # Need at least 4 lines for confidence
            median_angle = np.median(angles)
            angle_std = np.std(angles)
            
            print(f"📐 Detected: {median_angle:.2f}° (std: {angle_std:.2f})")
            
            # Apply same method regardless of tilt size, but only if consistent
            if (1.5 < abs(median_angle) and  # Only minimum threshold
                angle_std < 5.0):  # Good consistency
                
                # Small reduction toward zero (0.2-0.3 degrees)
                reduction = 0.25
                
                if median_angle > 0:
                    final_angle = median_angle - reduction
                else:
                    final_angle = median_angle + reduction
                
                (h, w) = image.shape[:2]
                center = (w // 2, h // 2)
                M = cv2.getRotationMatrix2D(center, final_angle, 1.0)
                straightened = cv2.warpAffine(image, M, (w, h), flags=cv2.INTER_CUBIC,
                                            borderMode=cv2.BORDER_REPLICATE)
                print(f"🔄 Gentle correction: {median_angle:.1f}° → {final_angle:.1f}°")
                return straightened
            else:
                if abs(median_angle) <= 1.5:
                    print("✅ Already straight enough")
                elif angle_std >= 5.0:
                    print("⚠️  Lines inconsistent - skipping")
    
    return image

def force_perfect_rectangle(points):
    """Force points to form a perfect rectangle using averaged dimensions"""
    rect = order_points(points)
    (tl, tr, br, bl) = rect
    
    # Calculate average width and height from all sides
    width_top = np.linalg.norm(tr - tl)
    width_bottom = np.linalg.norm(br - bl)
    height_left = np.linalg.norm(bl - tl)
    height_right = np.linalg.norm(br - tr)
    
    avg_width = int((width_top + width_bottom) / 2)
    avg_height = int((height_left + height_right) / 2)
    
    # Create perfect rectangle points
    perfect_rect = np.array([
        [0, 0],
        [avg_width, 0],
        [avg_width, avg_height], 
        [0, avg_height]
    ], dtype=np.float32)
    
    return perfect_rect, avg_width, avg_height

def perfect_rectangle_transform(image, pts):
    """Perspective transform that forces perfect rectangular output"""
    # Get the original ordered points
    src_rect = order_points(pts)
    
    # Calculate perfect rectangle dimensions
    dst_rect, width, height = force_perfect_rectangle(pts)
    
    # Calculate transformation matrix
    M = cv2.getPerspectiveTransform(src_rect, dst_rect)
    
    # Apply transformation
    warped = cv2.warpPerspective(image, M, (width, height),
                                borderMode=cv2.BORDER_REPLICATE,
                                flags=cv2.INTER_CUBIC)
    
    print(f"📐 Perfect rectangle: {width}x{height}")
    return warped

def scan_document_optimized(image_path, model_path="yolov8n.pt", 
                           save_path="scanned_doc.jpg", filter_mode="original"):
       
    # Load YOLO model
    model = YOLO(model_path)
    
    # Load image with better preprocessing
    image = cv2.imread(image_path)
    if image is None:
        print("❌ Error: Could not load image")
        return None
        
    orig = image.copy()
    orig_height, orig_width = image.shape[:2]
    
    # Resize image for faster processing if too large
    if max(orig_height, orig_width) > 1500:
        scale = 1500 / max(orig_height, orig_width)
        image = cv2.resize(image, None, fx=scale, fy=scale)
        print(f"📐 Image resized to {image.shape[1]}x{image.shape[0]}")
    
    # Run YOLO detection
    try:
        results = model(image)
        boxes = results[0].boxes.xyxy.cpu().numpy()
        classes = results[0].boxes.cls.cpu().numpy().astype(int)
    except Exception as e:
        print(f"❌ YOLO detection failed: {e}")
        return None
    
    # Pick largest 'book' box (class 73 in COCO)
    selected_box, max_area = None, 0
    for box, cls in zip(boxes, classes):
        if cls == 73:
            x1, y1, x2, y2 = map(int, box)
            area = (x2 - x1) * (y2 - y1)
            if area > max_area:
                max_area = area
                selected_box = (x1, y1, x2, y2)
    
    warped = None
    processing_method = "Unknown"
    
    if selected_box is not None:
        x1, y1, x2, y2 = selected_box
        
        # Adaptive padding based on image size
        PAD_X = max(20, int((x2 - x1) * 0.05))
        PAD_Y = max(20, int((y2 - y1) * 0.05))
        
        x1 = max(0, x1 - PAD_X)
        y1 = max(0, y1 - PAD_Y)
        x2 = min(image.shape[1], x2 + PAD_X)
        y2 = min(image.shape[0], y2 + PAD_Y)
        
        cropped = image[y1:y2, x1:x2]
        
        # Find best contour
        contour = find_best_contour(cropped)
        
        if contour is not None and len(contour) >= 3:
            # Simplify contour
            peri = cv2.arcLength(contour, True)
            approx = cv2.approxPolyDP(contour, 0.02 * peri, True)
            
            if len(approx) == 4:
                pts = approx.reshape(4, 2)
                processing_method = "4-point contour"
            else:
                # Fit minimum area rectangle for non-quadrilateral contours
                rect = cv2.minAreaRect(contour)
                box = cv2.boxPoints(rect)
                pts = order_points(box)
                processing_method = "min area rectangle"
            
            # Convert points back to original image coordinates
            pts[:, 0] += x1
            pts[:, 1] += y1
            
            # Apply enhanced perspective transform
            warped = enhanced_four_point_transform(image, pts)
            print(f"📐 Perspective correction applied ({processing_method})")
            
        else:
            # Fallback: Use YOLO crop with edge detection
            warped = enhance_cropped_document(cropped)
            processing_method = "YOLO crop with enhancement"
            print("⚠️ No good contour found, using enhanced YOLO crop")
            
    else:
        print("⚠️ No document detected, trying full image processing")
        # Try to find document in entire image
        contour = find_best_contour(image)
        if contour is not None:
            peri = cv2.arcLength(contour, True)
            approx = cv2.approxPolyDP(contour, 0.02 * peri, True)
            if len(approx) == 4:
                pts = approx.reshape(4, 2)
                warped = enhanced_four_point_transform(image, pts)
                processing_method = "Full image contour"
    
    # Apply filter and save
    if warped is not None:
        processed = apply_enhanced_filter(warped, filter_mode)
        # Conservative straightening only if clearly needed
        processed = balanced_straighten(processed)
        cv2.imwrite(save_path, processed)
        print(f"💾 Saved {filter_mode} scan at {save_path}")
        
        # Show results
        display_results(orig, processed, filter_mode, processing_method)
        return processed
    else:
        print("❌ Document processing failed")
        final_fallback_image = orig
        cv2.imwrite(save_path, final_fallback_image)
        display_results(orig, final_fallback_image, "original (fallback)", "Failed Document Detection")
        print(f"💾 Saved original image as fallback at {save_path}")
        return final_fallback_image
        return None

def enhance_cropped_document(cropped):
    """Enhance cropped document when contour detection fails"""
    # First try the improved rotation correction
    result = auto_rotate_to_horizontal(cropped)
    
    # If auto-rotation didn't work, fall back to Hough Lines method
    if np.array_equal(result, cropped):
        gray = cv2.cvtColor(cropped, cv2.COLOR_BGR2GRAY)
        edges = cv2.Canny(gray, 50, 150, apertureSize=3)
        
        lines = cv2.HoughLines(edges, 1, np.pi/180, threshold=100)
        
        if lines is not None:
            angles = []
            for rho, theta in lines[:, 0]:
                angle = np.degrees(theta) - 90
                if -45 <= angle <= 45:  # Only consider near-horizontal lines
                    angles.append(angle)
            
            if angles:
                median_angle = np.median(angles)
                if abs(median_angle) > 1:  # Only rotate if significant angle
                    (h, w) = cropped.shape[:2]
                    center = (w // 2, h // 2)
                    M = cv2.getRotationMatrix2D(center, median_angle, 1.0)
                    result = cv2.warpAffine(cropped, M, (w, h), 
                                           flags=cv2.INTER_CUBIC,
                                           borderMode=cv2.BORDER_REPLICATE)
                    print(f"🔄 Hough-based rotation by {median_angle:.2f} degrees")
    
    return result

def apply_enhanced_filter(image, mode="original"):
    """Enhanced filters with better document processing"""
    if mode == "original":
        return image
    
    if len(image.shape) == 3:
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    else:
        gray = image.copy()

    if mode == "bw":
        # Improved adaptive threshold
        return cv2.adaptiveThreshold(
            gray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
            cv2.THRESH_BINARY, 21, 10
        )
    
    elif mode == "lighttext":
        # Enhanced faint text detection
        clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
        enhanced = clahe.apply(gray)
        return enhanced
    
    elif mode == "gray":
        return gray
    
    elif mode == "enhanced":
        # Comprehensive enhancement
        # Noise reduction
        denoised = cv2.fastNlMeansDenoising(gray)
        # Contrast enhancement
        clahe = cv2.createCLAHE(clipLimit=3.0, tileGridSize=(8, 8))
        enhanced = clahe.apply(denoised)
        return enhanced
    
    else:
        raise ValueError(f"Unknown filter mode: {mode}")

def display_results(original, processed, filter_mode, method):
    """Display original and processed images"""
    plt.figure(figsize=(15, 6))
    
    plt.subplot(1, 2, 1)
    plt.imshow(cv2.cvtColor(original, cv2.COLOR_BGR2RGB))
    plt.title("Original Image")
    plt.axis("off")
    
    plt.subplot(1, 2, 2)
    if len(processed.shape) == 2:
        plt.imshow(processed, cmap="gray")
    else:
        plt.imshow(cv2.cvtColor(processed, cv2.COLOR_BGR2RGB))
    plt.title(f"Scanned ({filter_mode})\nMethod: {method}")
    plt.axis("off")
    
    plt.tight_layout()
    plt.show()

PROCESSED_FOLDER = "processed"
os.makedirs(PROCESSED_FOLDER, exist_ok=True)

def process_uploaded_image(image_path, save_path="processed_image.jpg", filter_mode="enhanced"):
    """
    Process the uploaded image and save the result to save_path.
    """
    result = scan_document_optimized(
        image_path=image_path,
        save_path=save_path,
        filter_mode=filter_mode
    )
    return save_path if result is not None else None

