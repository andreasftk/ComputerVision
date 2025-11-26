import torch
import torchvision
import cv2
import numpy as np
import matplotlib.pyplot as plt
import os

# 1) Load the pre-trained Mask R-CNN model (trained on COCO)
model = torchvision.models.detection.maskrcnn_resnet50_fpn(pretrained=True)
model.eval()

# 2) A function to run Mask R-CNN on an image and return all object masks
def get_all_objects_masks(image_bgr, score_threshold=0.5):
    """
    Given a BGR image, returns a list of:
      - boxes (x1, y1, x2, y2)
      - labels (COCO class IDs)
      - scores (confidence)
      - masks (each mask is a 2D numpy array of 0 or 255)
    Only returns detections with confidence above 'score_threshold'.
    """
    # Convert BGR to RGB
    image_rgb = cv2.cvtColor(image_bgr, cv2.COLOR_BGR2RGB)
    
    # Convert image to PyTorch tensor
    transform = torchvision.transforms.ToTensor()
    input_tensor = transform(image_rgb)
    
    # Run inference
    with torch.no_grad():
        outputs = model([input_tensor])[0]
    
    # Extract the outputs
    boxes = outputs["boxes"].cpu().numpy()       # shape: [N, 4]
    labels = outputs["labels"].cpu().numpy()     # shape: [N]
    scores = outputs["scores"].cpu().numpy()     # shape: [N]
    masks  = outputs["masks"].cpu().numpy()      # shape: [N, 1, H, W]
    
    # Filter by score threshold
    keep_indices = np.where(scores >= score_threshold)[0]
    
    boxes = boxes[keep_indices]
    labels = labels[keep_indices]
    scores = scores[keep_indices]
    masks = masks[keep_indices]
    
    # Convert each mask from [0..1] to {0, 255} by thresholding at 0.5
    binary_masks = []
    for m in masks:
        # m is shape [1, H, W]; threshold it
        m_thresh = (m[0] > 0.5).astype(np.uint8) * 255
        binary_masks.append(m_thresh)
    
    return boxes, labels, scores, binary_masks

def main():
    # Image file to process
    image_path = "../bench.jpg"  # or any other image
    image_bgr = cv2.imread(image_path)
    if image_bgr is None:
        print(f"Error: could not read {image_path}")
        return
    
    # Directory to save individual masks
    os.makedirs("output_masks", exist_ok=True)
    
    # Get all object masks above the score threshold
    boxes, labels, scores, binary_masks = get_all_objects_masks(image_bgr, score_threshold=0.5)
    
    # For visualization: draw bounding boxes and show masks
    # (Optional: you can skip if you only need the masks themselves)
    image_bgr_draw = image_bgr.copy()
    
    # COCO class names (1-based index; index 0 is “background”)
    # Shortened for brevity—full list has 91 entries; only first 80 are used.
    COCO_INSTANCE_CATEGORY_NAMES = [
        '__background__', 'person', 'bicycle', 'car', 'motorcycle', 'airplane', 'bus',
        'train', 'truck', 'boat', 'traffic light', 'fire hydrant', 'N/A', 'stop sign',
        'parking meter', 'bench', 'bird', 'cat', 'dog', 'horse', 'sheep', 'cow',
        'elephant', 'bear', 'zebra', 'giraffe', 'N/A', 'backpack', 'umbrella',
        'handbag', 'tie', 'suitcase', 'frisbee', 'skis', 'snowboard', 'sports ball',
        'kite', 'baseball bat', 'baseball glove', 'skateboard', 'surfboard',
        'tennis racket', 'bottle', 'wine glass', 'cup', 'fork', 'knife', 'spoon',
        'bowl', 'banana', 'apple', 'sandwich', 'orange', 'broccoli', 'carrot',
        'hot dog', 'pizza', 'donut', 'cake', 'chair', 'couch', 'potted plant',
        'bed', 'dining table', 'toilet', 'tv', 'laptop', 'mouse', 'remote',
        'keyboard', 'cell phone', 'microwave', 'oven', 'toaster', 'sink',
        'refrigerator', 'book', 'clock', 'vase', 'scissors', 'teddy bear',
        'hair drier', 'toothbrush'
    ]
    
    # Draw results on a copy of the image
    for i, box in enumerate(boxes):
        x1, y1, x2, y2 = box.astype(int)
        label_id = labels[i]
        score = scores[i]
        class_name = COCO_INSTANCE_CATEGORY_NAMES[label_id] if label_id < len(COCO_INSTANCE_CATEGORY_NAMES) else str(label_id)
        
        # Draw the bounding box
        color = (0, 255, 0)
        cv2.rectangle(image_bgr_draw, (x1, y1), (x2, y2), color, 2)
        cv2.putText(image_bgr_draw, f"{class_name} {score:.2f}", (x1, y1-5),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.7, color, 2)
        
        # Save the binary mask to disk
        mask_filename = f"output_masks/{os.path.splitext(os.path.basename(image_path))[0]}_{class_name}_mask_{i}.png"
        cv2.imwrite(mask_filename, binary_masks[i])
    
    # Show the result
    # Left: original image, Right: bounding boxes on image
    fig, axes = plt.subplots(1, 2, figsize=(12, 6))
    
    axes[0].imshow(cv2.cvtColor(image_bgr, cv2.COLOR_BGR2RGB))
    axes[0].set_title("Original Image")
    axes[0].axis('off')
    
    axes[1].imshow(cv2.cvtColor(image_bgr_draw, cv2.COLOR_BGR2RGB))
    axes[1].set_title("Mask R-CNN Detections")
    axes[1].axis('off')
    
    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    main()
