var createButton = document.getElementById('create');
createButton.addEventListener('click', alertCreateValues);


function alertCreateValues() {
    var items = document.getElementById('items').value;
    var stock = document.getElementById('stock').value;
    var price = document.getElementById('price').value;
    var listingId = document.getElementById('listing_id').value;

    var url = new URL('/create/create.py', window.location.origin);
    url.searchParams.append('items', items);
    url.searchParams.append('stock', stock);
    url.searchParams.append('price', price);
    url.searchParams.append('listing_id', listingId);
    url.searchParams.append('account', localStorage.getItem('account'));
    url.searchParams.append('password', localStorage.getItem('password'));


    fetch(url)
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok: ' + response.statusText);
            }
            return response.text();
        })
        .then(data => {
            alert('Success: ' + data);
        })
        .catch((error) => {
            alert('Error: ' + error.message);
        });
}

