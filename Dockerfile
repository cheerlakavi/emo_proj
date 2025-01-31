# Stage 1: Build Frontend
FROM node:18 AS frontend-builder

# Set working directory
WORKDIR /app/demopage

# Copy package files first (for better caching)
COPY demopage/package.json demopage/package-lock.json ./

# Install frontend dependencies
RUN npm install --legacy-peer-deps

# Copy the entire frontend code
COPY demopage/ ./

# Build React (Vite)
RUN npm run build


# Stage 2: Backend (Flask API)
FROM python:3.10-slim AS backend

# Install system dependencies
RUN apt-get update && apt-get install -y libgl1-mesa-glx && apt-get clean

# Set working directory
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

# Copy built frontend files from frontend-builder stage
COPY --from=frontend-builder /app/demopage/dist /usr/share/nginx/html

# Expose frontend port
EXPOSE 80


# Final Stage: Running Flask API + Nginx
FROM python:3.10-slim AS final

# Install system dependencies
RUN apt-get update && apt-get install -y libgl1-mesa-glx nginx && apt-get clean

# Set working directory
WORKDIR /app

# Copy Flask backend files
COPY app.py ana.py requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy uploads directory (if any)
COPY uploads /app/uploads

# Copy built frontend files from frontend-server stage
COPY --from=frontend-server /usr/share/nginx/html /app/frontend

# Expose Flask API & Frontend ports
EXPOSE 5000
EXPOSE 80

# Run Flask API and Nginx together
CMD ["sh", "-c", "service nginx start && python3 app.py"]
