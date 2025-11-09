from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
import os
import base64
import uuid
from model_logic import process_uploaded_image

app = FastAPI()

# Create folders
UPLOAD_FOLDER = "uploads"
PROCESSED_FOLDER = "processed"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(PROCESSED_FOLDER, exist_ok=True)

@app.post("/process-multiple")
async def process_multiple_images(files: list[UploadFile] = File(...)):
    if not files:
        raise HTTPException(status_code=400, detail="No files uploaded")

    processed_images_b64 = []

    for file in files:
        if file.content_type not in ["image/jpeg", "image/png"]:
            continue  # skip non-image files

        # Save uploaded image
        file_path = os.path.join(UPLOAD_FOLDER, file.filename)
        with open(file_path, "wb") as f:
            f.write(await file.read())

        # Generate unique output filename
        output_filename = f"{uuid.uuid4().hex}.jpg"
        output_path = os.path.join(PROCESSED_FOLDER, output_filename)

        # Process image and save to processed folder
        result = process_uploaded_image(file_path, save_path=output_path, filter_mode="enhanced")
        if result:
            # Read processed file and encode to base64
            with open(output_path, "rb") as img_file:
                encoded_string = base64.b64encode(img_file.read()).decode("utf-8")
            processed_images_b64.append(encoded_string)

    if not processed_images_b64:
        raise HTTPException(status_code=500, detail="No images were processed")

    return JSONResponse(content={"processed_images": processed_images_b64})

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
