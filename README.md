# Pizel: Smart Document Scanner with Perspective Transformation 📱📄

**Pizel** is a dual-mode mobile document scanner that bridges the gap between automated speed and manual precision. Built with **Flutter** and **FastAPI**, it utilizes a hybrid AI approach (YOLOv8 + OpenCV) to detect, crop, perspective-correct, and enhance documents in real-time.

---

## 🚀 Key Features

### 🔹 Dual-Path Processing
* **Automate PDF:** One-tap processing that detects the document, corrects the perspective, and enhances the image instantly.
* **Manual Mode:** Gives users granular control to crop and edit images before generating the PDF.

### 🔹 Smart Detection Engine
* **Hybrid AI:** Uses **YOLOv8** for object detection (context) and **OpenCV** for precise contouring.
* **Multi-Method Fusion:** Runs Otsu, Adaptive Thresholding, and Canny Edge Detection in parallel to handle shadows and poor lighting conditions.
* **Robust Fallbacks:** Implements a 4-level fallback system (including `find_best_contour` and `enhance_cropped_document`) to ensure scanning never fails.

### 🔹 Advanced Image Processing
* **Perspective Correction:** Automatically warps and "straightens" skewed documents using a custom 4-point transform.
* **Roll/Tilt Correction:** Detects text orientation and rotates the image to be perfectly horizontal.
* **Enhancement Filters:** Includes "Magic Color" (CLAHE) and "Black & White" (Adaptive Gaussian) modes for superior readability.

### 🔹 PDF Management
* **Multi-Image Support:** Capture or import multiple images to create a single PDF.
* **Local Storage:** Save, share, and manage generated PDFs directly from the app.

---

## 🛠️ Tech Stack

| Component | Technology | Purpose |
| :--- | :--- | :--- |
| **Frontend** | Flutter (Dart) | UI, Camera Access, Local Storage, API Calls |
| **Backend** | FastAPI (Python) | Image Processing Orchestration, API Endpoints |
| **Core Logic** | OpenCV & YOLOv8 | Computer Vision, Object Detection, Warping |
| **Communication**| HTTP Multipart | Efficient transfer of high-res images |

---

## ⚙️ Setup & Installation

### Prerequisites
* **Flutter SDK** installed.
* **Python 3.8+** installed.
* **Android Studio** or **VS Code**.

### 1. Backend Setup (Server)
The backend handles the heavy image processing logic.

```bash
# Clone the repository
git clone [https://github.com/yourusername/pizel-scanner.git](https://github.com/yourusername/pizel-scanner.git)

# Navigate to the backend directory
cd backend

# Create a virtual environment (optional but recommended)
python -m venv venv
source venv/bin/activate  # On Windows use `venv\Scripts\activate`

# Install dependencies
pip install -r requirements.txt

# Run the FastAPI server
# The server will typically start on [http://127.0.0.1:8000](http://127.0.0.1:8000)
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
