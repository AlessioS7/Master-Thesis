import os
from requests import Session
from requests.adapters import HTTPAdapter, DEFAULT_POOLSIZE, DEFAULT_RETRIES, DEFAULT_POOLBLOCK


class DNSResolverHTTPSAdapter(HTTPAdapter):
    def __init__(self, common_name, host, pool_connections=DEFAULT_POOLSIZE, pool_maxsize=DEFAULT_POOLSIZE,
                 max_retries=DEFAULT_RETRIES, pool_block=DEFAULT_POOLBLOCK):
        self.__common_name = common_name
        self.__host = host
        super(DNSResolverHTTPSAdapter, self).__init__(pool_connections=pool_connections, pool_maxsize=pool_maxsize,
                                                      max_retries=max_retries, pool_block=pool_block)

    def get_connection(self, url, proxies=None):
        redirected_url = url.replace(self.__common_name, self.__host)
        return super(DNSResolverHTTPSAdapter, self).get_connection(redirected_url, proxies=proxies)

    def init_poolmanager(self, connections, maxsize, block=DEFAULT_POOLBLOCK, **pool_kwargs):
        pool_kwargs['server_hostname'] = self.__common_name
        pool_kwargs['assert_hostname'] = self.__common_name
        super(DNSResolverHTTPSAdapter, self).init_poolmanager(connections, maxsize, block=block, **pool_kwargs)


common_name = 'httpbin.example.com'
host = '35.230.56.225'
port = 443
topic_name = 'my-topic'
jwt = os.getenv['JWT']
base_url = 'https://{}:{}/'.format(common_name, port)
my_session = Session()
my_session.mount(base_url, DNSResolverHTTPSAdapter(common_name, host))
default_response_kwargs = {
    'headers': {'Content-Type': 'application/vnd.kafka.json.v2+json',
                'Authorization': "".join(['Bearer ', jwt]),
                'Host': 'httpbin.example.com'},
    'verify': '../../security/tlsCertificates/example.com.crt'
}
