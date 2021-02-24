import Urbit from "@urbit/http-api";
import { memoize } from 'lodash';

// Memoize records (for the session) the information retrieved from Urbit.authenticate
// which is the return of the promise of authentication; basically an API token that we
// can use later for poke and subscribe actions
//
// Note, also, that you can change the ship against which you authenticate using the 
// ship name, url, and code arguments in the authenticate element below
//
const useApi = memoize(async () => {
    const urb = await Urbit.authenticate({ ship: 'nus', url: 'localhost:8080', code: 'bortem-pinwyl-macnyx-topdeg', verbose: true});
    return urb;
});

export default useApi;