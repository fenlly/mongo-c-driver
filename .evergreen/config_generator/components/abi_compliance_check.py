from shrub.v3.evg_command import EvgCommandType
from shrub.v3.evg_command import s3_put
from shrub.v3.evg_task import EvgTask

from config_generator.etc.function import Function
from config_generator.etc.utils import bash_exec


class CheckABICompliance(Function):
    name = 'abi-compliance-check'
    commands = [
        bash_exec(
            command_type=EvgCommandType.SETUP,
            working_dir='mongoc',
            script='.evergreen/scripts/abi-compliance-check-setup.sh'
        ),
        bash_exec(
            command_type=EvgCommandType.TEST,
            add_expansions_to_env=True,
            working_dir='mongoc',
            script='.evergreen/scripts/abi-compliance-check.sh'
        ),
        s3_put(
            aws_key='${aws_key}',
            aws_secret='${aws_secret}',
            bucket='mciuploads',
            content_type='text/html',
            display_name='ABI Compliance Check: ',
            local_files_include_filter='abi-compliance/compat_reports/**/compat_report.html',
            permissions='public-read',
            remote_file='${project}/${build_variant}/${revision}/${version_id}/${build_id}/abi-compliance/compat_reports/',
        ),
    ]

    @classmethod
    def call(cls, **kwargs):
        return cls.default_call(**kwargs)


def functions():
    return CheckABICompliance.defn()


def tasks():
    return [
        EvgTask(
            name=CheckABICompliance.name,
            commands=[CheckABICompliance.call()],
        )
    ]
