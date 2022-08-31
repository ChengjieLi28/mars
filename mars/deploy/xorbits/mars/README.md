# Azure deploy
## Azure Pipeline

## Run on Master
You can run `azure/deploy.sh` on the master machine to deploy mars.

1. You should build your own mars image and push to `xorbits/mars` namespace
   ```bash
   docker build -t xorbits/mars:<your_unique_version> -f azure/Dockerfile .
   docker push xorbits/mars:<your_unique_version>
   ```

2. Run `deploy.sh` on master machine using the unique version id mentioned above.
   ```bash
   azure/deploy.sh -c <your_unique_version> -h <host_file_path> -s <supervisor_ip> -w <worker_num> --local
   ```

3. Run TPCH query
   ```bash
   run_query.sh -p <mars_tpch_query_scirpt_path> -e <endpoint> -q <queries> -f <tpch_data_folder>
   ```

## Note
- For performance reasons, deploying mars will kill any other running docker containers present in the system.
