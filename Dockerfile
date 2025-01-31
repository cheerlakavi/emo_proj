# Stage 1: Build React Frontend
FROM node:18 AS frontend-builder

WORKDIR /app/demopage

# Copy dependencies first (for caching)
COPY demopage/package.json demopage/package-lock.json ./
RUN npm install --legacy-peer-deps

# Copy the rest of the frontend files
COPY demopage/ ./

# Build the frontend
RUN npm run build

# Stage 2: Build Flask Backend
FROM python:3.10-slim AS backend

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y libgl1-mesa-glx && apt-get clean

# Copy backend files
COPY app.py ana.py requirements.txt ./
COPY uploads /app/uploads

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose Flask API port
EXPOSE 5000

# Stage 3: Serve React with Nginx
FROM nginx:alpine AS frontend-server

# Copy built React frontend to Nginx
COPY --from=frontend-builder /app/demopage/dist /usr/share/nginx/html

# Copy custom Nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose React frontend port
EXPOSE 80

# Stage 4: Final Image (Backend + Frontend + Nginx)
FROM python:3.10-slim AS final

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y libgl1-mesa-glx && apt-get clean

# Copy Flask backend
COPY --from=backend /app /app

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy React build from frontend-server stage
COPY --from=frontend-server /usr/share/nginx/html /app/frontend

# Expose Flask API and React frontend ports
EXPOSE 5000
EXPOSE 80

# Start Flask backend
CMD ["python", "app.py"]
