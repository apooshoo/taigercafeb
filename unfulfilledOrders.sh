#!/bin/bash



init(){
	list=$1
	inputOrder=$2
	inputDate=$3


	# echo $inputOrder
	# echo $inputDate

	# rough logic:
	# read list
	# 	for each item, split into date, time, order, fulfilled
	# 	if order and date and fulfilled all match, add to array
	# 		while adding to array, loop through array
	# 			for each item, since order and date and fulfilled both match already, compare time only
	# 			SIMPLE+EASY VERSION: add if empty, else loop though and compare time. SLOW!!
	# 				if DATE i<[0], insert at 0
	# 				if i>[length-1], insert at end
	# 				else loop through array from 1 to length-1
	# 					if i>[i-1] AND i<[i+1], insert
	# 			MORE EFFICIENT VERSION: aim for logN.
	# 				if your time [yours] bigger than lastIndex or smaller than 0? if so, insert there.
	# 				else
	# 				find midpoint index of array (leftIndex=0, rightIndex=length-1), mid = those/2, try rounding with awk)
	# 					if [yours] > [mid]
	# 						if [yours] < [mid+1]
	# 							insert in between
	# 							break (STOP CONDITION)
	# 						else
	# 							find midpt of the right half of the array (mid, rightIndex)
	# 					else if [yours] < [mid]
	# 						if [yours] > [mid-1]
	# 							insert in between
	# 							break (STOP CONDITION)
	# 						else
	# 							find midpt of left half of the array (leftIndex, mid)
	# 				test: if I go left-right-left: it will be (0, length-1) left> (0, mid) right>  (newMid, oldMid) left> (oldMid, newMid)
	# 	Now you should have a sorted results array from left to right.
	# 	if results array.length > 3, print all
	# 	else for loop from i=0 to i<3 to print

	#init results array
	resultsArray=()

	while read orderItem; do
		# split order to get components
		IFS=" "
		read -ra orderItemParts <<< "$orderItem"
			# for i in "${orderItemParts[@]}"
			# do
			# 	echo $i
			# done


		#because i don't know how to properly split without splitting multi-word orders, work backward
		length="${#orderItemParts[@]}"
		# echo $length

		fulfilledString="${orderItemParts[$((length-1))]}"
			# echo $fulfilledString
		fulfilledBool=${fulfilledString:10}
			# echo $fulfilledBool

		#since we know when order starts and when fulfilled starts, we know where order ends
		#combine them to get order string
		orderString=""
		orderStringStartIndex=2
		orderStringEndIndex=$((length-2))
		#since we have removed whitespace, add them back between combines to get complete orderString
		for ((i=$orderStringStartIndex; i<=$orderStringEndIndex; i++))
		do
			if [ "$orderString" != "" ]
			then
				orderString+=" "
			fi
			#combine
			orderString+="${orderItemParts[i]}"
		done
			# echo "$orderString"

		#remove "order==" and  ""
		orderLength=${#orderString}
			# echo $orderLength
		order=${orderString:7:$orderLength-8}
			# echo $order

		#now prepare dates for comparison
		formattedInputDate="${inputDate//-/""}"
			# echo $formattedInputDate
		formattedOrderDate="${orderItemParts[0]//-/""}"
			# echo $formattedOrderDate


		# now we have date, order, fulfilled
		# check if this orderItem satisfies these conditions
		#if true, add to resultsArray
		if [ "$order" == "$inputOrder" ] && [ "${formattedInputDate}" == "${formattedOrderDate}" ] && [ "$fulfilledBool" == "FALSE" ]
		then
			# UNSORTED INSERT
			# resultsArray+=("$orderItem")

			#SORTED INSErt
			orderTime="${orderItemParts[1]}"
			formattedOrderTime="${orderTime//:/""}"
			# insert "${resultsArray[@]}" "0" "${#resultsArray[@]}" $formattedOrderTime $orderItem

			echo "starting insert"

			# if resultsArray is empty, no need to sort, just insert
			if [ ${#resultsArray[@]} == "0" ]
			then
				echo "length 0, adding"
				resultsArray+=("$orderItem")
			# if resultsArray is not empty, loop through it. if next element is bigger than current, insert at current. else, continue loop
			elif [ ${#resultsArray[@]} == "1" ]
			then
				echo "length 1, checking"
				# get the formatted order time of the element
				IFS=" "
				read -ra onlyOrderItemParts <<< "${resultsArray[0]}"
				onlyOrderTime="${onlyOrderItemParts[1]}"
				formattedOnlyOrderTime="${onlyOrderTime//:/""}"

				#compare and insert. Doing this way to force integer read
				if [ $((formattedOrderTime-formattedOnlyOrderTime)) -lt 0 ]
				then
					resultsArray=( "$orderItem" "${resultsArray[@]}" )
				else
					resultsArray=( "${resultsArray[@]}" "$orderItem" )
				fi
			# if resultsArray has more than one element, loop until next element is bigger
			else
				echo "length more than 1"
				#loop
				lengthOfResultsArray="${#resultsArray[@]}"
					# echo $lengthOfResultsArray
				for (( i=0; i<lengthOfResultsArray; i++ ))
				do
					#if formattedOrderTime is the biggest (i+1 = length and loop is complete)
					if [ $i -eq $lengthOfResultsArray ]
					then
						resultsArray=( "${resultsArray[@]}" "$orderItem" )
						break
					fi

					# else, get the formatted order time of the next element
					IFS=" "
					read -ra nextOrderItemParts <<< "${resultsArray[((i+1))]}"
					nextOrderTime="${nextOrderItemParts[1]}"
					formattedNextOrderTime="${nextOrderTime//:/""}"
					echo "$formattedNextOrderTime"

					#compare. if formattedOrderTime < formattedNextOrderTime, insert
					if [ $((formattedOrderTime-formattedNextOrderTime)) -lt 0 ]
					then
						echo "inserting at index $i"
						# gets all from 0 to before i, add new, get all from i to end
						resultsArray=( "${resultsArray[@]:0:$i}" "$orderItem" "${resultsArray[@]:$i}" )
						break
					fi

				done

			fi
			echo "ending insert"

		fi

	done <$list


	#now we have results array, print out the first 3
	echo
	echo "Final Array"
	for i in "${resultsArray[@]}"
	do
		echo "$i"
	done
}

init "$@"


	# 			SIMPLE+EASY VERSION: add if empty, else loop though and compare time. SLOW!!
	# 				if DATE i<[0], insert at 0
	# 				if i>[length-1], insert at end
	# 				else loop through array from 1 to length-1
	# 					if i>[i-1] AND i<[i+1], insert
	# 			MORE EFFICIENT VERSION: aim for logN.
	# 				if your time [yours] bigger than lastIndex or smaller than 0? if so, insert there.
	# 				else
	# 				find midpoint index of array (leftIndex=0, rightIndex=length-1), mid = those/2, try rounding with awk)
	# 					if [yours] > [mid]
	# 						if [yours] < [mid+1]
	# 							insert in between
	# 							break (STOP CONDITION)
	# 						else
	# 							find midpt of the right half of the array (mid, rightIndex)
	# 					else if [yours] < [mid]
	# 						if [yours] > [mid-1]
	# 							insert in between
	# 							break (STOP CONDITION)
	# 						else
	# 							find midpt of left half of the array (leftIndex, mid)
	# 				test: if I go left-right-left: it will be (0, length-1) left> (0, mid) right>  (newMid, oldMid) left> (oldMid, newMid)
	# 	Now you should have a sorted results array from left to right.
	# 	if results array.length > 3, print all
	# 	else for loop from i=0 to i<3 to print