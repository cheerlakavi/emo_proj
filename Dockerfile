# Stage 1: Build React Frontend
FROM node:18 AS frontend-builder

# Set working directory for React frontend
WORKDIR /app/demopage

# Copy React frontend code
COPY demopage/package.json demopage/package-lock.json ./
COPY demopage/ ./

# Install dependencies and build the frontend
RUN npm install && npm run build

# Stage 2: Build Flask Backend
FROM python:3.10-slim AS backend

# Install system dependencies for OpenCV and DeepFace (without libgthread-2.0-0)
RUN apt-get update && apt-get install -y \
    libglib2.0-0 libglib2.0-dev libsm6 libxext6 libxrender-dev \
    ffmpeg && \
    apt-get clean

# Set working directory for Flask backend
WORKDIR /app

# Copy backend files
COPY app.py ana.py requirements.txt ./

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy uploads directory (if any)
COPY uploads /app/uploads

# Expose Flask API port
EXPOSE 5000

# Stage 3: Serve React with Nginx
FROM nginx:alpine AS frontend-server

# Copy the build from the frontend-builder stage
COPY --from=frontend-builder /app/demopage/dist /usr/share/nginx/html

# Expose port for React frontend
EXPOSE 80

# Stage 4: Final Image (Backend + Frontend + Nginx)
FROM python:3.10-slim AS final

# Install system dependencies for OpenCV and DeepFace (without libgthread-2.0-0)
RUN apt-get update && apt-get install -y \
    libglib2.0-0 libglib2.0-dev libsm6 libxext6 libxrender-dev \
    ffmpeg && \
    apt-get clean

# Set working directory
WORKDIR /app

# Copy the Flask backend files
COPY app.py ana.py requirements.txt ./

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy uploads directory (if any)
COPY uploads /app/uploads

# Copy the React build from the frontend-server stage
COPY --from=frontend-server /usr/share/nginx/html /app/frontend

# Expose port for React (nginx) and Flask API
EXPOSE 80
EXPOSE 5000

# Install gunicorn to serve Flask in production
RUN pip install gunicorn

# Run Flask app using gunicorn (as a production WSGI server)
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
