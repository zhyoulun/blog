## CI概要介绍

https://docs.gitlab.com/17.1/ee/ci/index.html

![](/static/images/2406/p001.png)

其中gitlab的cicd只是其中的第三步

## yaml语法

https://docs.gitlab.com/17.1/ee/ci/yaml/


## 复杂example

```yaml
test-job:
  script:
    - echo "This is my first job!"
    - date
```

![](/static/images/2406/p002.png)

## 字段作用备忘

### image

https://docs.gitlab.com/17.1/ee/ci/quick_start/tutorial.html

`image`: Tell the runner which Docker container to use to run the job in. The runner:

- Downloads the container image and starts it.
- Clones your GitLab project into the running container.
- Runs the script commands, one at a time.

### artifacts

artifacts: Jobs are self-contained and do not share resources with each other. If you want files generated in one job to be used in another job, you must save them as artifacts first. Then later jobs can retrieve the artifacts and use the generated files.

### stage and stages

The most common pipeline configurations group jobs into stages. Jobs in the same stage can run in parallel, while jobs in later stages wait for jobs in earlier stages to complete. If a job fails, the whole stage is considered failed and jobs in later stages do not start running.

### allow_failure

Jobs that fail intermittently, or are expected to fail, can slow down productivity or be difficult to troubleshoot. Use allow_failure to let jobs fail without halting pipeline execution.

### dependencies

Use dependencies to control artifact downloads in individual jobs by listing which jobs to fetch artifacts from.

### rules

Add rules to each job to configure in which pipelines they run. You can configure jobs to run in merge request pipelines, scheduled pipelines, or other specific situations. Rules are evaluated from top to bottom, and if a rule matches, the job is added to the pipeline.

### Hidden jobs

Jobs that start with . are never added to a pipeline. Use them to hold configuration you want to reuse.

### extends

Use extends to repeat configuration in multiple places, often from hidden jobs. If you update the hidden job’s configuration, all jobs extending the hidden job use the updated configuration.

### default

Set keyword defaults that apply to all jobs when not defined.

### YAML overriding

When reusing configuration with extends or default, you can explicitly define a keyword in the job to override the extends or default configuration.