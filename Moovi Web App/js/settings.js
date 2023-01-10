// Intanzia gli oggetti di local e session storage utili per il recupero e il salvataggio dei dati
// Per recuperare un valore dalla local storage --> oLocalStorage.get(etichetta, default)
// Per salvare un valore nella local storage --> oLocalStorage.set(etichetta, valore)
// Per recuperare un valore dalla session storage --> oSessionStorage.get(etichetta, default)
// Per salvare un valore nella session storage --> oSessionStorage.set(etichetta, valore)

var DataSession_Load = function () {

    // Tutta la gestione del local storage
    oLocalStorage = new Settings();
    oLocalStorage.setDataStorage(new DataStorage("moovi_"));

    // Tutta la gestione del session storage
    oSessionStorage = new Settings();
    oSessionStorage.setDataStorage(new DataStorage("moovi_", true));
}

// Contiene tutti gli oggetti di salvataggio e recupero di session o local storage
class Settings {

    constructor(name = "app_settings") {
        this.name = name;
        this.ds = null;
    }

    setDataStorage(ds) {
        this.ds = ds;
    }

    getDataStorage() {
        return this.ds;
    }

    getData() {
        try {
            var data = this.ds.get(this.name);
            if (data == null) {
                this.ds.set(this.name, {});
                return this.getData();
            }
            return data
        } catch (e) {
            console.error(e);
             return null
        }
    }

    get(key, _default) {
        try {
            return this.getData()[key] || _default;
        } catch (e) {
            console.error(e);
            return _default ? _default : null;
        }
    }

    set(key, val) {
        try {
            var data = this.getData();
            data[key] = val;
            this.ds.set(this.name, data);
        } catch (e) {
            console.error(e);
        }
    }

    remove(key) {
        try {
            var data = this.getData()
            delete data[key];
            this.ds.set(this.name, data);
        } catch (e) {
            console.error(e);
        }
    }

    clear() {
        try {
            this.ds.remove(this.name)
        } catch (e) {
            console.error(e);
        }
    }

}

// Utile per capire se session o local e serializza e deserializza gli oggetti
// Utilizzata da Settings
class DataStorage {

    constructor(prefix = "", isSessionStorage = false) {
        this.isSessionStorage = isSessionStorage;
        this.setPrefix(prefix);
        this.encrypt = false;
    }

    setPrefix(prefix = "") {
        this.prefix = prefix;
    }

    getPrefix() {
        return this.prefix;
    }

    getStorage() {
        if (this.isSessionStorage) {
            return sessionStorage;
        } else {
            return localStorage;
        }
    }

    get(_key, _default) {
        try {
            var d = this.getStorage().getItem(this.prefix + _key);
            if (d == null) return null;
            d = (this.encrypt) ? JSON.parse(window.atob(d)) : JSON.parse(d)
            return d.data || _default;
        } catch (e) {
            console.error(e);
            return _default ? _default : null;
        }
    }

    set(_key, _value) {
        try {
            var d = {
                data: _value
            };
            d = JSON.stringify(d)
            d = (this.encrypt) ? window.btoa(d) : d;
            this.getStorage().setItem(this.prefix + _key, d);
        } catch (e) {
            console.error(e);
        }
    }

    remove(_key) {
        try {
            this.getStorage().removeItem(this.prefix + _key)
        } catch (e) {
            console.error(e);
        }
    }

    clear() {
        for (var _key in this.getStorage()) {
            if (_key.indexOf(this.prefix) > -1) {
                this.getStorage().removeItem(_key);
            }
        }
    }

}
