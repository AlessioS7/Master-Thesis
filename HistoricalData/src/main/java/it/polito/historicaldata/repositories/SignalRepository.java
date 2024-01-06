package it.polito.historicaldata.repositories;

import it.polito.historicaldata.entities.Signal;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SignalRepository extends MongoRepository<Signal, String> {
    List<Signal> getSignalsByCity(String city);

    Optional<Signal> getSignalByZoneId(String zoneId);

    List<Signal> getSignalsByTimestampBetween(String timestamp1, String timestamp2);

    List<Signal> getSignalsByCoordinatesBetween(String coordinates1, String coordinates2);
}
