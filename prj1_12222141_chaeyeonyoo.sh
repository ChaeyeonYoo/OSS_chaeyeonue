#!/bin/bash

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

U_ITEM="u.item"
U_DATA="u.data"
U_USER="u.user"

USERNAME="유채연"
STUDENT_NUMBER="12222141"

echo "USERNAME: $USERNAME"
echo "Student Number: $STUDENT_NUMBER"

echo "[ MENU ]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
echo "2. Get the data of action genre movies from 'u.item’"
echo "3. Get the average 'rating’ of the movie identified by specific 'movie id' from 'u.data’"
echo "4. Delete the ‘IMDb URL’ from ‘u.item'"
echo "5. Get the data about users from 'u.user’"
echo "6. Modify the format of 'release date' in 'u.item’"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo "--------------------------"

while true; do

    read -p "Enter your choice [1-9]: " choice
    echo

    case $choice in
        1)
           read -p "Please enter 'movie id'(1~1682): " movie_id
           echo

           movie_data=$(awk -F '|' -v id="$movie_id" '$1 == id' "$U_ITEM")
           
           if [ -z "$movie_data" ]; then
                echo "No movie found with 'movie id' $movie_id."
           else
                echo "$movie_data"

           echo 
           fi
           ;;
        2)
            read -p "Do you want to get the data of ‘action’ genre movies from 'u.item’?(y/n): " yn
            echo
            if [[ $yn =~ ^[Yy]$ ]]; then
                awk -F '|' '$7 == "1" { print $1 " " $2 }' "$U_ITEM" | sort -t'|' -k1,1n | head -10
                echo
            else
                echo "Action genre movies display cancelled."
                echo
            
            fi
            ;;

        3)
            read -p "Please enter the 'movie id’(1~1682): " movie_id
            echo

            average=$(awk -v id=$movie_id 'BEGIN{sum=0; count=0} $2 == id {sum += $3; count++} END{if (count > 0) {avg = sum/count; printf("%.6f", avg)} else {print "No ratings for this movie ID."; exit 1}}' u.data)
            average_rounded=$(printf "%.5f" $average)
            echo "average rating of $movie_id: $average_rounded"
            echo
            ;;

        4)
            read -p "Do you want to delete the 'IMDb URL' from 'u.item'?(y/n): " choice
            echo

            if [ "$choice" == "y" ]; then
                sed 's|\([^|]*\)|\||5' u.item | head -n 10
                echo
            else
                echo "No changes made to 'u.item'."
                echo

            fi
            ;;

        5)
            read -p "Do you want to get the data about users from 'u.user'?(y/n): " answer
            echo

            if [ "$answer" = "y" ]; then
                sed -n -e 's/^\([^|]*\)|\([^|]*\)|M|\([^|]*\)|.*/user \1 is \2 years old male \3/p' \
                        -e 's/^\([^|]*\)|\([^|]*\)|F|\([^|]*\)|.*/user \1 is \2 years old female \3/p' u.user | head -n 10
            
            echo
            fi
            ;;

        6)
            read -p "Do you want to Modify the format of ‘release date’ in ‘u.item’?(y/n): " yn
            echo

            if [ "$yn" == "y" ]; then
                LC_ALL=C sed -i '.bak' -E 's|([0-9]{2})-Jan-|199501\1|g;
                               s|([0-9]{2})-Feb-|199502\1|g;
                               s|([0-9]{2})-Mar-|199503\1|g;
                               s|([0-9]{2})-Apr-|199504\1|g;
                               s|([0-9]{2})-May-|199505\1|g;
                               s|([0-9]{2})-Jun-|199506\1|g;
                               s|([0-9]{2})-Jul-|199507\1|g;
                               s|([0-9]{2})-Aug-|199508\1|g;
                               s|([0-9]{2})-Sep-|199509\1|g;
                               s|([0-9]{2})-Oct-|199510\1|g;
                               s|([0-9]{2})-Nov-|199511\1|g;
                               s|([0-9]{2})-Dec-|199512\1|g' "$U_ITEM"

                tail -n 10 "$U_ITEM"
                echo
            else
                echo "Release date format will not be modified."
                echo

            fi
            ;;

        7)
            read -p "Please enter the ‘user id’(1~943): " user_id
            echo

            movie_ids=$(awk -v uid="$user_id" '$1==uid {print $2}' u.data | sort -n | tr '\n' '|')
    
            movie_ids_formatted=$(echo "$movie_ids" | sed 's/|$//')
            echo $movie_ids_formatted
            echo

            echo "$movie_ids" | tr '|' '\n' | head -10 | while read movie_id; do
                movie_title=$(grep "^$movie_id|" u.item | cut -d'|' -f2)
                echo "$movie_id|$movie_title"

            done

            echo
            ;;


        8)
            read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n): " answer
            echo

            if [ "$answer" == "y" ]; then

                programmers=$(awk -F'|' '$2 >= 20 && $2 <= 29 && $4 == "programmer" {printf "%s ", $1}' u.user)

                for i in $(seq 1 1682); do
                    average=$(awk -v movie_id="$i" -v ids="$programmers" 'BEGIN{
                        split(ids,idList," ")
                        for (i in idList) idIndex[idList[i]]
                        count = 0
                        sum = 0
                    }
                    ($2 == movie_id) && ($1 in idIndex){
                        sum += $3
                        count++
                    }
                    END{
                        if (count > 0) {
                            printf("%d %.5g\n", movie_id, sum/count)
                        }
                    }' "u.data")

                    if [ ! -z "$average" ]; then
                        echo "$average"
                    fi
                done

            echo
            fi
            ;;

        9)
            echo "Bye!"
            exit 0
            ;;
        *)
            echo "Invalid choice. Please enter a number from 1 to 9."
            ;;
    esac

done
