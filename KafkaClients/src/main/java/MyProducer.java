import org.apache.kafka.clients.CommonClientConfigs;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.Producer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.config.SslConfigs;
import org.json.simple.JSONObject;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.security.spec.KeySpec;
import java.util.Properties;

public class MyProducer {

    public static void main(String[] args) {
        try (InputStream input = new FileInputStream("KafkaClients\\src\\main\\resources\\client-ssl-auth.properties")) {

            Properties props = new Properties();

            // load a properties file
            props.load(input);

            //props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, System.getenv("BOOTSTRAP_SERVER"));
            //props.put(CommonClientConfigs.SECURITY_PROTOCOL_CONFIG, "SSL");
            //props.put(SslConfigs.SSL_TRUSTSTORE_TYPE_CONFIG, "PEM");
            //props.put(SslConfigs.SSL_TRUSTSTORE_CERTIFICATES_CONFIG, System.getenv("CA_CRT"));
            //props.put(SslConfigs.SSL_TRUSTSTORE_LOCATION_CONFIG, System.getenv("TRUSTSTORE_LOCATION"));
            //props.put(SslConfigs.SSL_TRUSTSTORE_PASSWORD_CONFIG, System.getenv("TRUSTSTORE_PASSWORD"));

            props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringSerializer");
            props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringSerializer");

            Producer<String, String> producer = new KafkaProducer<>(props);
            for (int i = 0; i < 10; i++) {
                JSONObject key = new JSONObject();
                key.put("JSON1", Integer.toString(i));

                JSONObject value = new JSONObject();
                value.put("field1", Integer.toString(i));
                value.put("field2", Integer.toString(i) + 1);
                value.put("field3", Integer.toString(i) + 2);

                System.out.println(value.toString());

                System.out.printf("Producing for topic '%s' key '%s' and value '%s'\n", System.getenv("TOPIC_NAME"), key, value);
                producer.send(new ProducerRecord<>(System.getenv("TOPIC_NAME"), key.toString(), value.toString()));
            }

            producer.close();
        } catch (IOException ex) {
            ex.printStackTrace();
        }
    }
}
