# Use the NVIDIA CUDA image with cuDNN and Ubuntu 22.04 as a base
FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

# Set noninteractive environment variable for non-interactive apt-get install
ENV DEBIAN_FRONTEND noninteractive

# Set the working directory inside the container
WORKDIR /tatia

# Update and install dependencies
RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y libgl1 libglib2.0-0 wget git git-lfs python3-pip python-is-python3 \
    && rm -rf /var/lib/apt/lists/*

# Copy the requirements file into the container
COPY ./requirements.txt /tatia/requirements.txt

RUN pip install -U pip setuptools wheel
RUN pip install -U spacy
RUN python -m spacy download fr_dep_news_trf

# Install Python dependencies from the requirements file
RUN pip install --no-cache-dir --upgrade -r /tatia/requirements.txt

# Install ipykernel for Jupyter
RUN pip install --no-cache-dir ipykernel

# Create a new user named "user" with user ID 1000 and without a password
RUN useradd -m -u 1000 user

# Set the default user to "user"
USER user

# Set environment variables for the "user"
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

# Set the working directory to the user's home directory
WORKDIR $HOME/app

# Copy the current directory contents into the container at $HOME/app and set the owner to the users
COPY --chown=user:user . $HOME/app

# Expose the port Jupyter will listen on
EXPOSE 8888

# Configure Jupyter Notebook server
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--NotebookApp.token=''", "--NotebookApp.password=''"]