var purchaseButton = document.getElementById('buy');
purchaseButton.addEventListener('click', purchaseListing);

function purchaseListing() {
    var listingId = document.getElementById('listing_id').value;
    var price = document.getElementById('price').value;

    var url = new URL('/purchase/purchase.py', window.location.origin);
    url.searchParams.append('id', listingId);
    url.searchParams.append('price', price);
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
