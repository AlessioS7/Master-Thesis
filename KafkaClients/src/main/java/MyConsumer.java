import org.apache.kafka.clients.CommonClientConfigs;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.config.SslConfigs;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.time.Duration;
import java.util.Arrays;
import java.util.Properties;

public class MyConsumer {

    public static void main(String[] args) {
        try (InputStream input = new FileInputStream("KafkaClients\\src\\main\\resources\\client-ssl-auth.properties")) {

            Properties props = new Properties();

            // load a properties file
            props.load(input);

            // props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, System.getenv("BOOTSTRAP_SERVER"));
            //props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest"); // DEFAULT IS LATEST
            // props.put("enable.auto.commit", "false"); // DEFAULT IS TRUE
            // props.put("auto.commit.interval.ms", "1000"); // WORKS ONLY IF enable.auto.commit IS TRUE AND THE DEFAULT VALUE IS 5000 (5s)
            //props.put(CommonClientConfigs.SECURITY_PROTOCOL_CONFIG, "SSL");
            //props.put(SslConfigs.SSL_TRUSTSTORE_TYPE_CONFIG, "PEM"); // DEFAULT IS JKS
            //props.put(SslConfigs.SSL_TRUSTSTORE_CERTIFICATES_CONFIG, System.getenv("CA_CRT"));
            //props.put(SslConfigs.SSL_TRUSTSTORE_LOCATION_CONFIG, System.getenv("TRUSTSTORE_LOCATION"));
            //props.put(SslConfigs.SSL_TRUSTSTORE_PASSWORD_CONFIG, System.getenv("TRUSTSTORE_PASSWORD"));

            props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringDeserializer");
            props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringDeserializer");
            props.put("group.id", "g1");

            KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props);
            consumer.subscribe(Arrays.asList(System.getenv("TOPIC_NAME"), "test"));

            while (true) {
                ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));
                for (ConsumerRecord<String, String> record : records)
                System.out.printf("offset = %d, key = %s, value = %s, partition=%s%n", record.offset(), record.key(), record.value(), record.partition());            }
        } catch (IOException ex) {
            ex.printStackTrace();
        }
    }
}
