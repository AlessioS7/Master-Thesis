package it.polito.historicaldata;

import it.polito.historicaldata.entities.Signal;
import it.polito.historicaldata.exceptions.SignalNotFoundException;
import it.polito.historicaldata.repositories.SignalRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
public class HistoricalDataController {
    private final SignalRepository signalRepository;
    private final Logger LOG = LoggerFactory.getLogger(getClass());

    public HistoricalDataController(SignalRepository signalRepository) {
        this.signalRepository = signalRepository;
    }

    @RequestMapping("/test")
    public String test() {
        LOG.info("TEST HISTORICAL DATA SERVICE");
        return "TEST HISTORICAL DATA SERVICE";
    }

    @RequestMapping("/signals/all")
    public List<Signal> getAllSignals() {
        LOG.info("Getting all signals");
        return signalRepository.findAll();
    }

    @RequestMapping("/signals/{city}")
    public List<Signal> getSignalsByCity(@PathVariable String city) {
        LOG.info("Getting signals by city");
        return signalRepository.getSignalsByCity(city);
    }

    @RequestMapping("/signals/timestamp/{timestamp1}/{timestamp2}")
    public List<Signal> getSignalsByTimestampBetween(@PathVariable String timestamp1, @PathVariable String timestamp2) {
        LOG.info("Getting signals by timestamp between");
        return signalRepository.getSignalsByTimestampBetween(timestamp1, timestamp2);
    }

    @RequestMapping("/signals/coordinates/{coordinates1}/{coordinates2}")
    public List<Signal> getSignalsByCoordinatesBetween(@PathVariable String coordinates1, @PathVariable String coordinates2) {
        LOG.info("Getting signals by coordinates between");
        return signalRepository.getSignalsByCoordinatesBetween(coordinates1, coordinates2);
    }

    @RequestMapping("/signals/{zoneId}")
    public Signal getSignalByZone(@PathVariable String zoneId) throws SignalNotFoundException {
        LOG.info("Getting signal by zone");
        Optional<Signal> s = signalRepository.getSignalByZoneId(zoneId);
        if(s.isEmpty()) throw new SignalNotFoundException();
        return s.get();
    }

    @ResponseStatus(HttpStatus.NOT_FOUND)
    @ExceptionHandler(SignalNotFoundException.class)
    public void invalidZoneId(SignalNotFoundException e) { }
}
