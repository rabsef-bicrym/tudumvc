import Urbit from "@urbit/http-api";
import { memoize } from 'lodash';

// Memoize records (for the session) the information retrieved from Urbit.authenticate
// which is the return of the promise of authentication; basically an API token that we
// can use later for poke and subscribe actions
//
const useApi = memoize(async () => {
    const urb = await Urbit.authenticate({ ship: 'nus', url: '138.197.192.56:8080', code: 'bortem-pinwyl-macnyx-topdeg', verbose: true});
    return urb;
});

export default useApi;